# coding=UTF-8
#!/usr/bin/python
# -*- coding:utf8 -*-
# 热更游戏服务
# feilong

import os
import curses
import locale
import time
import sys
import socket
import StringIO
import threading
import socket


service_info = {
    'loginserver' : 17103,
}

addr = '127.0.0.1'
socket_list = {}
service_name = "manager_service"
file_name = ""
can_close = False

def on_exit():
    for svr_name, tmp_socket in socket_list.items():
        tmp_socket.close()

def connect_service():
    for svr_name, port in service_info.items():
        tmp_socket = socket.socket(family=socket.AF_INET,type=socket.SOCK_STREAM)
        tmp_socket.connect((addr,port))
        recv_str = tmp_socket.recv(4096)
        socket_list[svr_name] = tmp_socket

def recv_service_info(svr_name,tmp_socket):
    try:
        tmp_str = "list \r\n"
        tmp_socket.send(tmp_str)
        recv_str = tmp_socket.recv(4096)
        while not recv_str.find('<CMD OK>') >= 0:
            recv_str += tmp_socket.recv(4096)

        si = StringIO.StringIO(recv_str)
        all_lines = si.readlines()
        all_lines = all_lines[0: len(all_lines) -1]
        svr_list = []
        for s in all_lines:
            s = s.strip().split()
            if s[2].find(service_name) >= 0 :
                print(s[0], s[2])
                svr_list.append(s[0].split(":")[1])

        if len(svr_list) > 0 :
            # print(svr_list)
            tmp_socket.send("clearcache \r\n") #清除缓存
            recv_str = tmp_socket.recv(4096)
            while not recv_str.find('<CMD OK>') >= 0:
                recv_str += tmp_socket.recv(4096)
        else :
            print("no this service_name ", service_name)

        for svr_id in svr_list :          
            # print("___svr_id",svr_id)  
            tmp_str = "call "+svr_id+ " 'hotfix','" + file_name + "'" +"\r\n"
            print(tmp_str)
            tmp_socket.send(tmp_str)
            recv_str = tmp_socket.recv(4096)
            while not recv_str.find('<CMD OK>') >= 0:
                recv_str += tmp_socket.recv(4096)            
            si = StringIO.StringIO(recv_str)
            all_lines = si.readlines()
            all_lines = all_lines[0: len(all_lines) -1]            
            for s in all_lines:
                print(s.strip())
                

        global can_close
        can_close = True
    except: 
        tmp_socket.close() 
        socket_list.pop(svr_name) 
 
# 
def get_service_list(): 
    connect_service()             
    for svr_name, tmp_socket in socket_list.items(): 
        recv_service_info(svr_name,tmp_socket) 
  
 
 
if __name__ == '__main__': 
    # print(sys.argv[0])
    # print(sys.argv[1])
    
    if len(sys.argv)==2 :
        service_name = str(sys.argv[1]).strip() #服务名
    if len(sys.argv)==3 :       
        service_name = str(sys.argv[1]).strip() #服务名 
        file_name = str(sys.argv[2]).strip() #文件模块名
    thread = threading.Thread(target=get_service_list) 
    thread.setDaemon(True) 
    thread.start()

    while 1:
        if can_close == True :
            break
        time.sleep(2);
        break;

    on_exit()
