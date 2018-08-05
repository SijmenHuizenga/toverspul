package main

import (
	"os"
	"crypto/aes"
	"crypto/cipher"
	"io"
	"fmt"
	"strings"
)

func main(){
	fmt.Print("enter decryption password:")
	var input string
	fmt.Scanln(&input)
	decryptfile(os.Args[1], os.Args[2], strings.TrimSpace(input))
}

func decryptfile(infilename string, outfilename string, encryptionkey string) {
	inFile, err := os.Open(infilename)
	if err != nil {
		panic(err)
	}
	defer inFile.Close()

	block, err := aes.NewCipher([]byte(encryptionkey))
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
