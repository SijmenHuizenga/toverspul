package main

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/robfig/cron"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"
	"syscall"
	"time"
)

const EnvBucket = "BUCKET"
const EnvCron = "CRON"
const EnvName = "NAME"

const TarTarget = "/tmp.tar.gz"
const TarTargetEncrypted = "/tmp.enc"

const BackupSrcFolder = "/backup"
const BackupEncryptionKeyfile = "/run/secrets/passfile"
const CredentialsFile = "/run/secrets/aws-credentials"

func main() {
	sess, err := openAwsSession()

	encryptionkey, err := ioutil.ReadFile(BackupEncryptionKeyfile)
	if err != nil {
		log.Fatal(err)
	}
	encryptionkey = []byte(strings.TrimSpace(string(encryptionkey)))

	bucket := os.Getenv(EnvBucket)
	name := os.Getenv(EnvName)
	cronpattern := os.Getenv(EnvCron)

	c := cron.New()
	c.AddFunc(cronpattern, func() {
		backup(encryptionkey, bucket, name, sess)
	})
	c.Run()
}

func backup(encryptionkey []byte, bucket string, backupname string, session *session.Session) {
	if empty, err := isEmpty(BackupSrcFolder); err != nil {
		log.Println("Skipping backup " + backupname + " because " + BackupSrcFolder + " empty check errored: " + err.Error())
		return
	} else if empty {
		log.Println("Skipping backup " + backupname + " because " + BackupSrcFolder + " is empty.")
		return
	}

	if err := backupDirectory(BackupSrcFolder, encryptionkey, bucket, backupname, session); err == nil {
		log.Println("Backup "+backupname+" is complete.")
	}else {
		log.Println("Backup "+backupname+" failed: " + err.Error())
	}

	log.Println("Starting backup cleanup...")
	if err := cleanupOldBackups(bucket, backupname, session); err  == nil {
		log.Println("Backup cleanup finished")
	} else {
		log.Println("Backup cleanup of "+backupname+" failed: " + err.Error())
	}
}

func backupDirectory(dir string, encryptionkey []byte, bucket string, backupname string, session *session.Session) error {
	ensureEmptyWorkspace()
	err := targz(dir, TarTarget)
	if err != nil {
		return err
	}

	err = encryptfile(TarTarget, TarTargetEncrypted, encryptionkey)
	if err != nil {
		return err
	}

	return uploadToAws(session, TarTargetEncrypted, bucket, targetfilename(backupname))
}

func ensureEmptyWorkspace() {
	deleteIfExist(TarTarget)
	deleteIfExist(TarTargetEncrypted)
}

func deleteIfExist(target string){
	if _, err := os.Stat(target); err == nil {
		os.Remove(target)
	}
}

const fileFormat = "2006-01-02 15:04:05"
const fileSuffix = ".tar.gz.eas256"

func targetfilename(name string) string {
	return name + "/" + time.Now().Format(fileFormat) + fileSuffix
}

func targz(dir string, targetfile string) error {
	//https://unix.stackexchange.com/a/61760
	stdout, stderr, exitcode := runCommand("tar", "czf", targetfile, "--warning=no-file-changed", "-C", "/", dir[1:])

	// https://www.gnu.org/software/tar/manual/html_section/tar_19.html#Synopsis
	// Status code 0 = sccessful termination
	// Status code 1 = Some file differ //todo: handle this code differently
	// Status code 2 = failure
	if exitcode != 1 && exitcode != 0 {
		return fmt.Errorf("tarring directory %v failed(%d): %v, %v", dir, exitcode, stderr, stdout)
	}
	return nil
}

func openAwsSession() (*session.Session, error) {
	tmp, err := session.NewSession(&aws.Config{
		Region:      aws.String(endpoints.EuCentral1RegionID),
		Credentials: credentials.NewSharedCredentials(CredentialsFile, "default"),
	})
	if err != nil {
		return nil, err
	}
	return tmp, nil
}

func uploadToAws(session *session.Session, filename string, bucket string, targetpath string) error {
	uploader := s3manager.NewUploader(session)

	f, err := os.Open(filename)
	if err != nil {
		return fmt.Errorf("failed to open file %q, %v", filename, err)
	}

	_, err = uploader.Upload(&s3manager.UploadInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(targetpath),
		Body:   f,
	})
	if err != nil {
		return fmt.Errorf("failed to upload file, %v", err)
	}
	return nil
}

var schedule = map[int64]int64{
	7: 7,      // 7 daily
	30: 10,    // 10 every month so every
	12*30: 12, // 1 every month for 12 months
}

func shouldBackupBeKept(x int64) bool {
	/*
	t = Tijd is dat deze reeks backups bewaard moet worden.
	n = Aantal backups dat je in die tijd wil bewaren.
	x = Dagnummer waarop de backup is gemaakt. Getal start op 01-01-1970

	Bijvoorbeeld
	  7 dagelijkse (t=7, n=7)
	  6 maandelijkse (t=30, n=6)

	Als x > t dan kan de backup altijd weg.
	Als x <= t en x is deelbaar door t/n dan moet die bewaard blijven.
	*/

	now := time.Now()
	currentDay := int64(now.Year()) * int64(365) + int64(now.YearDay())

	for t, n := range schedule {
		if x >= currentDay-t && x % (t/n) == 0 {
			return true
		}
	}
	return false
}

func cleanupOldBackups(bucket string, name string, session *session.Session) error {
	sss := s3.New(session)
	listResult, err := sss.ListObjectsV2(&s3.ListObjectsV2Input{
		Prefix: aws.String(name),
		Bucket: aws.String(bucket),
	})
	if err != nil {
		return err
	}
	for _, obj := range listResult.Contents {
		key := aws.StringValue(obj.Key)
		dateString := strings.TrimPrefix(strings.TrimSuffix(key, fileSuffix), name + "/")
		dateTime, err := time.Parse(fileFormat, dateString)
		if err != nil {
			log.Println("Invalid backup filename: " + key, err)
			continue
		}
		dateDay := int64(dateTime.Year()) * int64(365) + int64(dateTime.YearDay())
		if shouldBackupBeKept(dateDay) {
			log.Println("Keeping backup " + key)
		} else {
			log.Println("Deleting backup " + key)
			//_, err := sss.DeleteObject(&s3.DeleteObjectInput{
			//	Key: obj.Key,
			//	Bucket: aws.String(bucket),
			//})
			//if err != nil {
			//	log.Println(err)
			//}
		}
	}
	return nil
}

func encryptfile(infilename string, outfilename string, encryptionkey []byte) error {
	inFile, err := os.Open(infilename)
	if err != nil {
		return err
	}
	defer inFile.Close()

	block, err := aes.NewCipher(encryptionkey)
	if err != nil {
		return err
	}

	var iv [aes.BlockSize]byte
	stream := cipher.NewOFB(block, iv[:])

	outFile, err := os.OpenFile(outfilename, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		return err
	}
	defer outFile.Close()

	writer := &cipher.StreamWriter{S: stream, W: outFile}

	if _, err := io.Copy(writer, inFile); err != nil {
		return err
	}
	return nil
}

//thanks to https://stackoverflow.com/a/30708914/2328729
func isEmpty(name string) (bool, error) {
	f, err := os.Open(name)
	if err != nil {
		return false, err
	}
	defer f.Close()

	_, err = f.Readdirnames(1) // Or f.Readdir(1)
	if err == io.EOF {
		return true, nil
	}
	return false, err // Either not empty or error, suits both cases
}

//with thanks to https://stackoverflow.com/a/40770011/2328729
func runCommand(name string, args ...string) (stdout string, stderr string, exitCode int) {
	var outbuf, errbuf bytes.Buffer
	cmd := exec.Command(name, args...)
	cmd.Stdout = &outbuf
	cmd.Stderr = &errbuf

	err := cmd.Run()
	stdout = outbuf.String()
	stderr = errbuf.String()

	if err != nil {
		// try to get the exit code
		if exitError, ok := err.(*exec.ExitError); ok {
			ws := exitError.Sys().(syscall.WaitStatus)
			exitCode = ws.ExitStatus()
		} else {
			// This will happen (in OSX) if `name` is not available in $PATH,
			// in this situation, exit code could not be get, and stderr will be
			// empty string very likely, so we use the default fail code, and format err
			// to string and set to stderr
			log.Printf("Could not get exit code for failed program: %v, %v", name, args)
			exitCode = 3
			if stderr == "" {
				stderr = err.Error()
			}
		}
	} else {
		// success, exitCode should be 0 if go is ok
		ws := cmd.ProcessState.Sys().(syscall.WaitStatus)
		exitCode = ws.ExitStatus()
	}
	return
}