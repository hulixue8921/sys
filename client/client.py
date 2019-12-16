import json
import Page.index
import Page.netset
import Th
import socket
import struct
import tkinter.messagebox
import operator
import tkinter
from Func import *

class  client ():
    def __init__(self,**args):
        self.args=args
        self.func={'1add':addProject , '2add':addOrder,'css':css}
        self.index();
        return
    def Receve(self):
        lock.acquire()

        self.con=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        self.con.connect((self.args['host'],self.args['port']))
        while 1:
                bytenum=struct.unpack('!L', self.con.recv(4))[0]
                data=self.con.recv(int(bytenum)).decode('utf-8')
                info=json.loads(data)
                print(info)
                if operator.eq(info['kind'],'info'):
                    self.message('提示', info['info'])
                elif operator.eq(info['kind'],'errorInfo'):
                    self.message('错误' ,info['info'])
                else:
                    if operator.eq(info['location'] , '3'):
                        self.func['css'](self,info)
                    else:
                        self.func[info['location']+info['action']](self,info)


        return

    def index(self):
        self.Index=Page.index.index(self);
        Th.th(self.Receve).start()
        self.Index.mainloop()
        return

    def  sent(self, arg):
        data=json.dumps(arg)+'\n';
        self.con.send(data.encode('utf-8'))
        return

    def  message(self, arg1,arg2):
        tkinter.messagebox.showinfo(arg1, arg2);
        return

lock=Th.lock();
c=client(host='172.23.3.247' , port=8000 );










