import tkinter
import tkinter.ttk

class new(tkinter.Toplevel):
    def __init__(self,client,data):
        super().__init__();
        self.client=client;
        self.data=data;
        self.title("取消项目命令关联")
        dataDone=dataDo(data);
        self.post=tkinter.StringVar();
        frame=tkinter.Frame(self);
        frame.pack(fill=tkinter.X,padx=80, pady=80);
        f1=tkinter.Frame(frame);
        f1.pack(fill=tkinter.X);
        f2=tkinter.Frame(frame);
        f2.pack(fill=tkinter.X)
        tkinter.Label(f1, text='取消项目命令').pack(side=tkinter.LEFT);
        tkinter.ttk.Combobox(f1,textvariable=self.post,values=dataDone).pack(side=tkinter.LEFT);
        tkinter.Button(f2,text='确定',command=self.commit).pack();
        return
    def commit(self):
        data={"title":self.data['data']['title'],"obj":"Order" , "action":"do" ,"user":"root" ,"pid":self.data['pid'] ,"oid":self.data['oid'],"arg":[self.post.get()]}
        self.client.sent(data)
        self.destroy();
        return

def dataDo(data):
    dataDone=[];
    for i in data['data']['project_order']:
        dataDone.append(i['pname']+'-'+i['oname'])
    return dataDone;

