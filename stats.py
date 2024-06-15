import subprocess
import urllib.request
import urllib.parse
import time
import socket
import cx_Oracle

def get_ip_address():
    try:
        hostname = socket.gethostname()
        ip_address = socket.gethostbyname(hostname)
        return ip_address
    except Exception as e:
        print("Error fetching IP address:", e)
        return "Unknown"

def get_filesystem_usage():
    command = "df -h | awk '$5+0>=50 {print $1, $5}'"
    try:
        result = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        filesystems = result.stdout.strip().split('\n')
        return filesystems
    except subprocess.CalledProcessError as e:
        print(f"An error occurred while executing the command: {e}")
        return []

def insert_stats_to_db(connection, server_name, ip_address, filesystem, usage):
    try:
        cursor = connection.cursor()
        sql = """
        INSERT INTO filesystem_usage (server_name, ip_address, filesystem, usage_percentage)
        VALUES (:server_name, :ip_address, :filesystem, :usage_percentage)
        """
        cursor.execute(sql, server_name=server_name, ip_address=ip_address, filesystem=filesystem, usage_percentage=usage)
        connection.commit()
        print("Filesystem stats inserted successfully into the database")
    except cx_Oracle.DatabaseError as e:
        print("Error inserting stats into the database:", e)
    finally:
        cursor.close()

def main():
    print("Server monitoring script is running...")
    server_name = socket.gethostname() 
    ip_address = get_ip_address()  

   
    hostname = "192.168.137.132"  
    port = 1521  
    service_name = "XE"  
    username = "system"  
    password = "root123"  

  
    dsn = cx_Oracle.makedsn(hostname, port, service_name=service_name)
    
    connection = cx_Oracle.connect(user=username, password=password, dsn=dsn)

    try:
        while True:
            filesystems = get_filesystem_usage()
            for fs in filesystems:
                filesystem, usage = fs.split()
                print(f"Server: {server_name}, IP Address: {ip_address}, Filesystem: {filesystem}, Usage: {usage}")
                insert_stats_to_db(connection, server_name, ip_address, filesystem, usage)
            time.sleep(5)  
    except Exception as e:
        print("An error occurred:", e)
    finally:
        connection.close()

if __name__ == "__main__":
    main()
