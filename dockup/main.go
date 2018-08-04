package main

import (
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"os"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"encoding/hex"
	"crypto/aes"
	"crypto/cipher"
	"io"
	"os/exec"
	"io/ioutil"
	"log"
	"time"
	"strings"
	"github.com/robfig/cron"
)

const EnvBucket = "BUCKET"
const EnvCron = "CRON"

const TarTarget = "/tmp.tar.gz"
const TarTargetEncrypted = "/tmp.enc"

const BackupSrcFolder = "/backup"
const BackupEncryptionKeyfile = "/run/secrets/passfile"
const CredentialsFile = "/run/secrets/aws-credentials"

func main() {
	sess, err := openAwsSession()

	encryptionkey, err := ioutil.ReadFile(BackupEncryptionKeyfile) // just pass the file name
	if err != nil {
		log.Fatal(err)
	}

	bucket := os.Getenv(EnvBucket)
	cronpattern := os.Getenv(EnvCron)

	c := cron.New()
	c.AddFunc(cronpattern, func() {
		backup(encryptionkey, bucket, sess)
	})
	c.Run()
}

func backup(encryptionkey []byte, bucket string, session *session.Session) {
	files, err := ioutil.ReadDir(BackupSrcFolder)
	if err != nil {
		log.Fatal(err)
	}

	for _, f := range files {
		if !f.IsDir() {
			continue
		}
		absolutedir := BackupSrcFolder + "/" + f.Name()
		err = backupDirectory(absolutedir, encryptionkey, bucket, session)
		if err == nil {
			log.Println("Backup of directory '" + absolutedir + "' is complete.")
		}else {
			log.Println("Backup of directory '" + absolutedir + "' failed: " + err.Error())
		}
	}
}

func backupDirectory(dir string, encryptionkey []byte, bucket string, session *session.Session) error {
	ensureEmptyWorkspace()
	err := targz(dir, TarTarget)
	if err != nil {
		return err
	}

	err = encryptfile(TarTarget, TarTargetEncrypted, encryptionkey)
	if err != nil {
		return err
	}

	return uploadToAws(session, TarTargetEncrypted, bucket, targetfilename(dir))
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

func targetfilename(dir string) string {
	folderlist := strings.Split(dir, "/")
	return folderlist[len(folderlist)-1] + "/" + time.Now().Format("2006-01-02 15:04:05") + ".tar.gz.eas256"
}

func targz(dir string, targetfile string) error {
	cmd := exec.Command("tar", "czf", targetfile, dir)

	if out, err := cmd.CombinedOutput(); err != nil {
		return fmt.Errorf("tarring directory %v failed: %v: \n%v", dir, err.Error(), string(out))
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

func decryptfile(infilename string, outfilename string, encryptionkey string) {
	key, _ := hex.DecodeString(encryptionkey)

	inFile, err := os.Open(infilename)
	if err != nil {
		panic(err)
	}
	defer inFile.Close()

	block, err := aes.NewCipher(key)
	if err != nil {
		panic(err)
	}

	var iv [aes.BlockSize]byte
	stream := cipher.NewOFB(block, iv[:])

	outFile, err := os.OpenFile(outfilename, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		panic(err)
	}
	defer outFile.Close()

	reader := &cipher.StreamReader{S: stream, R: inFile}
	if _, err := io.Copy(outFile, reader); err != nil {
		panic(err)
	}
}
