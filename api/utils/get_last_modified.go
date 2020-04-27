package utils

import (
	"os/exec"
	"time"
	"fmt"
)

//map used for caching the Last-Modified timestamps
var last_modified = make(map[string]string)

func GetLastModified(csv string) string {
	//if the last modified timestamp was already calculated use that
	if val, ok := last_modified[csv]; ok {
		return val
	}

	//execute git command to get last commit timestamp that modified the file
	cmd := exec.Command("git","log", "-1", "--pretty=\"%cD\" ", "../data/" + csv,)
	out, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println(err)
	}

	//convert the byte array to string
	commit_timestamp := string(out[1:len(out)-3])

	//parse the commit date
	commit_last_modified, terr := time.Parse(time.RFC1123Z, commit_timestamp)
	if terr != nil {
		fmt.Println(terr)
	}

	//create location object for GMT
	location, lerr := time.LoadLocation("GMT")
	if lerr != nil {
		fmt.Println(lerr)
	}

	//convert the time to GMT and output in RFC1123 format required by Last-Modified
	last_modified_formatted := commit_last_modified.In(location).Format(time.RFC1123)

	//store for quick retrieval next time
	last_modified[csv] = last_modified_formatted

	return last_modified_formatted
}
