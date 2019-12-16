import tkinter
import tkinter.ttk

class new(tkinter.Toplevel):
    def __init__(self,client ,data):
        super().__init__();
        self.client=client;
        self.data=data;
        self.title("添加命令样式")
        self.post=tkinter.StringVar();
        self.post1=tkinter.StringVar();
        self.post2=tkinter.StringVar();
        frame=tkinter.Frame(self);
        frame.pack(fill=tkinter.X,padx=80, pady=80);
        f1=tkinter.Frame(frame);
        f1.pack(fill=tkinter.X);
        f2=tkinter.Frame(frame);
        f2.pack(fill=tkinter.X)
        f3=tkinter.Frame(frame);
        f3.pack(fill=tkinter.X)
        f4=tkinter.Frame(frame);
        f4.pack(fill=tkinter.X)
        tkinter.Label(f1, text='样式名字').pack(side=tkinter.LEFT);
        tkinter.Entry(f1,textvariable=self.post).pack()
        tkinter.Label(f2, text='是否并发').pack(side=tkinter.LEFT);
        tkinter.Entry(f2,textvariable=self.post1).pack()
        tkinter.Label(f3, text='参数项').pack(side=tkinter.LEFT);
        tkinter.Entry(f3,textvariable=self.post2).pack()
        tkinter.Button(f4,text='确定',command=self.commit).pack();
        return
    def commit(self):
        data={"title":self.data['data']['title'],"obj":"Order" , "action":"do" ,"user":"root" ,"pid":self.data['pid'] ,"oid":self.data['oid'],"arg":[self.post.get(),self.post1.get() ,self.post2.get()]}
        self.client.sent(data)
        self.destroy();
        return
