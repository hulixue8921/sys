import tkinter
import Th
class netset(tkinter.Toplevel):
    def __init__(self, client):
        super().__init__();
        self.p=client.Index
        self.client=client
        self.config(width=200,height=200)
        self.Frame1=tkinter.Frame(self)
        self.Frame1.pack(fill=tkinter.X,padx=80, pady=80)
        self.title("网络不可用,是否重连")
        tkinter.Button(self.Frame1,text='是',bg='green',command=lambda:self.con()).pack(side=tkinter.LEFT,padx=10);
        tkinter.Button(self.Frame1,text='否',bg='red',command=lambda:self.discon()).pack(side=tkinter.LEFT,padx=10);
        return
    def con (self):
        Th.th(self.client.Receve).start()
        self.destroy();
        return
    def discon(self):
        self.destroy()
        self.p.destroy()
        return




