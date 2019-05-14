--进程端口相关配置

return {

    loginserver = {
        {
            cluster = "0.0.0.0:17001",
            disable = 0,
            ip = "127.0.0.1",
            port = 17101,   --socket端口
            port_ws = 17102, --websocket端口
            debug_port = 17103, 
            maxclient = 10000,
            gate_size = 1, --服务的个数        
        },     
    },


}

