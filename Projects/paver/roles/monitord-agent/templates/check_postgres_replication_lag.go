package main

import (
	"fmt"
	_ "github.com/lib/pq"
	"database/sql"
        //"log"	
        //"time"
        "encoding/json"
        "os"
        "net/http"
        "crypto/tls"
        "strings"
)



type Slave_lag struct {
    Seconds int
}

func main() {


        var db *sql.DB
        var err error

        db, err = sql.Open("postgres", "user=postgres dbname=gds host=localhost port=6432 sslmode=disable")

        if err != nil {
                fmt.Printf("sql.Open error: %v\n",err)
                return
        }

        defer db.Close()

      //var stmt *sql.Stmt
        var role string

        err = db.QueryRow("select pg_is_in_recovery()").Scan(&role)
        if err != nil {
                fmt.Printf("sql.Open error: %v\n",err)
                return
        }

        if role == "false" {
            fmt.Printf("MASTER\n")
            doMaster(db)
		   if err != nil {
                	fmt.Printf("Master error: %v\n",err)
               		return
        }
        }else {
            fmt.Printf("SLAVE\n")
            doSlave(db)
		   if err != nil {
                	fmt.Printf("Slave error: %v\n",err)
               		return
        }
        }


        
}


func doMaster(db *sql.DB) error {
	var err error

        doInsert(db, "insert into dba.replication_check(tstamp) values (now())")
        doInsert(db, "insert into dba.replication_status_m(sent_location,write_location,flush_location,tstamp) select sent_location,write_location,flush_location,now() from pg_stat_replication")

        err = sendJson(0)
        if err != nil {
                fmt.Printf("Json error: %v\n",err)
                return err
        }

	return nil
}


func doSlave(db *sql.DB) error {
	var err error
	var lag int

        err = db.QueryRow("select extract(epoch from now() - tstamp)::int as lag from dba.replication_check order by id desc limit 1").Scan(&lag)
        if err != nil {
                fmt.Printf("sql.Open error: %v\n",err)
                return err
        }
        fmt.Printf("The lag is -> %d \n", lag)
        err = sendJson(lag)
        if err != nil {
                fmt.Printf("Json error: %v\n",err)
                return err
        }

        //epistrefei json me tis kanonikes times      

	return nil
}



func doInsert(db *sql.DB,statement string) error {

        _, err := db.Query(statement)

        if err != nil {
                fmt.Printf("db.Query error: %v\n",err)
                return err
        }

        return nil
}



func sendJson(seconds int) error {

     m := &Slave_lag{
          Seconds: seconds}

        b, err :=json.Marshal(m)
        if err!=nil {
            panic(err)
        }

	os.Stdout.Write(b)


       in := strings.NewReader(string(b))

       req, err := http.NewRequest("POST","https://10.8.164.66:43191/module/httptrap/65cf76d5-5416-4cde-80f4-2a83679496ce/rgwg3gg35", in)

       req.Header.Set("Content-Type", "application/json")

       tr := &http.Transport{
              TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
        }
        client := &http.Client{Transport: tr}
        resp, err := client.Do(req)
        if err != nil {
              panic(err)
        }
              defer resp.Body.Close()

        fmt.Println("response Status:", resp.Status)
        fmt.Println("response Headers:", resp.Header)


        return nil
}

















