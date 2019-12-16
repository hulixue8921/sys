import tkinter
import tkinter.ttk

class new(tkinter.Toplevel):
    def __init__(self,client,data):
        super().__init__();
        self.client=client;
        self.data=data;
        self.title("命令关联样式")
        dataDone=dataDo(data);
        self.postrole=tkinter.StringVar();
        self.postproject=tkinter.StringVar();
        frame=tkinter.Frame(self);
        frame.pack(fill=tkinter.X,padx=80, pady=80);
        f1=tkinter.Frame(frame);
        f1.pack(fill=tkinter.X);
        f2=tkinter.Frame(frame);
        f2.pack(fill=tkinter.X)
        f3=tkinter.Frame(frame);
        f3.pack(fill=tkinter.X);
        tkinter.Label(f1, text='命令名').pack(side=tkinter.LEFT);
        tkinter.ttk.Combobox(f1,textvariable=self.postrole,values=dataDone[0]).pack(side=tkinter.LEFT);
        tkinter.Label(f2, text='样式名').pack(side=tkinter.LEFT);
        tkinter.ttk.Combobox(f2,textvariable=self.postproject,values=dataDone[1]).pack(side=tkinter.LEFT);
        tkinter.Button(f3,text='确定',command=self.commit).pack();
        return
    def commit(self):
        data={"title":self.data['data']['title'],"obj":"Order" , "action":"do" ,"user":"root" ,"pid":self.data['pid'] ,"oid":self.data['oid'],"arg":[self.postrole.get(), self.postproject.get()]}
        self.client.sent(data)
        self.destroy();
        return

def dataDo(data):
    dataDone=[];
    d1=[];
    d2=[];
    dataDone.append(d1);
    dataDone.append(d2);
    for i in data['data']['order']:
        d1.append(i['name'])
    for i in data['data']['css']:
        d2.append(i['name'])

    return dataDone;

