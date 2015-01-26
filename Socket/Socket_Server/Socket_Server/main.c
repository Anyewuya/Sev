//
//  main.c
//  Socket_Server
//
//  Created by TRY-MAC01 on 15-1-26.
//  Copyright (c) 2015年 ZH. All rights reserved.
//

#include <stdio.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>

#define PORT 9000

int main(int argc, const char * argv[]) {
    // insert code here...
    struct sockaddr_in server_addr;

    
    server_addr.sin_len = sizeof(server_addr);
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(PORT);
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);      //inet_addr("127.0.0.1");
    bzero(&(server_addr.sin_zero), 8);
    
    int server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket == -1) {
        perror("socket error");
        return 1;
    }
    printf("server_socket is ok");

    int bind_result = bind(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr));
    
    if (bind_result == -1) {
        perror("bind error");
        return 1;
    }
    printf("bind is ok");

    if (listen(server_socket, 10) == -1) {
        perror("listen error");
        return 1;
    }
    printf("linten is ok");

    struct sockaddr_in client_address;
    socklen_t address_len;
    
    int client_socket = accept(server_socket, (struct sockaddr *)&client_address, &address_len);
    
    if (client_socket == -1) {
        perror("accept error");
        return -1;
    }
    
    char recv_msg[1024];
    char reply_msg[1024];
//    char reply_msg[] = "reply is ok";

    printf("Hello, World!\n");

    while (1) {
        bzero(recv_msg, 1024);
        bzero(reply_msg, 1024);
        
        printf("reply:");
        scanf("%s", reply_msg);
        send(client_socket, reply_msg, 1024, 0);
        
        
        long byte_num = recv(client_socket, recv_msg, 1024, 0);
        recv_msg[byte_num] = '\0';
        printf("client said:%s\n", recv_msg);
    }
    
    return 0;
}
