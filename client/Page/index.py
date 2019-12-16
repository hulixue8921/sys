import tkinter
import operator

class index (tkinter.Tk):
    def __init__(self, client):
        super().__init__();
        self.geometry('1000x400')
        self.title('运维专用')
        self.client=client
        self.set();
        self.projects=[]
        return
    def set(self):
        self.username=tkinter.StringVar();
        self.passwd=tkinter.StringVar();
        #self.usernamereg=tkinter.StringVar();
        #self.passwdreg=tkinter.StringVar();
        self.Login=tkinter.Frame(self)
        self.Login.pack(side=tkinter.LEFT,fill=tkinter.Y,pady=120);
        self.w=tkinter.Canvas(self);
        self.w.pack(side=tkinter.LEFT,fill=tkinter.Y);
        self.w.create_line(100,0,100,300,fill='black' , dash=(4,4));
        self.Reg=tkinter.Frame(self)
        self.Reg.pack(side=tkinter.RIGHT,fill=tkinter.Y,pady=120);
        tkinter.Label(self.Login, text='登录').pack(fill=tkinter.X);
        self.Login1=tkinter.Frame(self.Login);
        self.Login1.pack(fill=tkinter.X,padx=10, pady=5);
        self.Login2=tkinter.Frame(self.Login);
        self.Login2.pack(fill=tkinter.X,padx=10,pady=5);
        self.Login3=tkinter.Frame(self.Login);
        self.Login3.pack(fill=tkinter.X,padx=100,pady=5);
        tkinter.Label(self.Login1, text='用户名').pack(side=tkinter.LEFT);
        tkinter.Entry(self.Login1 ,textvariable=self.username).pack(side=tkinter.LEFT)
        tkinter.Label(self.Login2, text='密码').pack(side=tkinter.LEFT);
        self.en=tkinter.Entry(self.Login2 ,textvariable=self.passwd,show='*')
        self.en.pack(side=tkinter.LEFT);
        tkinter.Checkbutton(self.Login2,text='是否显示密码',command=lambda:self.show(self.en)).pack(side=tkinter.LEFT);
        tkinter.Button(self.Login3,text='确定',command=lambda:self.commit(self.username,self.passwd)).pack(side=tkinter.LEFT);
        tkinter.Label(self.Reg, text='注册').pack(fill=tkinter.X);
        self.Reg1=tkinter.Frame(self.Reg);
        self.Reg1.pack(fill=tkinter.X,padx=10,pady=5);
        self.Reg2=tkinter.Frame(self.Reg);
        self.Reg2.pack(fill=tkinter.X,padx=10,pady=5);
        self.Reg3=tkinter.Frame(self.Reg);
        self.Reg3.pack(fill=tkinter.X,padx=100);
        tkinter.Label(self.Reg1, text='用户名').pack(side=tkinter.LEFT);
        tkinter.Entry(self.Reg1 ,textvariable=self.username).pack(side=tkinter.LEFT);
        tkinter.Label(self.Reg2, text='密码').pack(side=tkinter.LEFT);
        self.enreg=tkinter.Entry(self.Reg2 ,textvariable=self.passwd,show='*')
        self.enreg.pack(side=tkinter.LEFT);
        tkinter.Checkbutton(self.Reg2,text='是否显示密码',command=lambda:self.show(self.enreg)).pack(side=tkinter.LEFT);
        tkinter.Button(self.Reg3,text='确定',command=lambda:self.commitreg(self.username,self.passwd)).pack(side=tkinter.LEFT);
        return

    def forget(self):
        self.Login.pack_forget();
        self.w.pack_forget();
        self.Reg.pack_forget();
        return

    def commit(self,user, passwd):
        if len(user.get()) == 0:
            self.client.message('提示',"请填写账户名")
        elif len(passwd.get()) == 0:
            self.client.message('提示',"请填写密码")
        else:
            self.client.user=user.get()
            data={'user':user.get(), 'obj':'User', 'passwd':passwd.get() , 'action':'load'}
            self.client.sent(data)
            data['obj']="Projects"
            data['action']='get'
            data.pop('passwd')
            self.client.sent(data)
        return
    def commitreg(self, user,passwd):
        if len(user.get()) == 0:
            self.client.message('提示',"请填写账户名")
        elif len(passwd.get()) == 0:
            self.client.message('提示',"请填写密码")
        else:
            self.client.user=user.get()
            data={'user':user.get(), 'obj':'User', 'passwd':passwd.get() , 'action':'reg'}
            self.client.sent(data)
            data['obj']="Projects"
            data['action']='get'
            data.pop('passwd')
            self.client.sent(data)
        return

    def show(self,a):
        if operator.eq(a['show'] , '*'):
            a.config(show='')
        else:
            a.config(show='*')
        return
    def Destroy(self):
        self.destroy()






