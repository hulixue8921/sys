import tkinter
import tkinter.ttk

class new(tkinter.Toplevel):
    def __init__(self,client ,data):
        super().__init__();
        self.client=client;
        self.data=data;
        self.arg=data['data']['arg'].split('-');
        self.F=tkinter.Frame(self);
        self.F.pack(fill=tkinter.X,padx=80, pady=80)
        self.title(data['data']['title']);
        self.temp={}
        self.temp1={}

        for i in self.arg:
            self.temp[i]=tkinter.Frame(self.F)
            self.temp[i].pack(fill=tkinter.X)
            self.temp1[i]=tkinter.StringVar();
            tkinter.Label(self.temp[i],text=i).pack(side=tkinter.LEFT);
            tkinter.Entry(self.temp[i], textvariable=self.temp1[i]).pack(side=tkinter.LEFT);

        tkinter.Button(self,text='确定',command=self.commit).pack();


    def commit(self):
        data={}
        data['title']=self.data['data']['title']
        data["obj"]="Order"
        data["action"]="do"
        data["user"]=self.client.Index.username.get()
        data["pid"]=self.data['pid']
        data["oid"]=self.data['oid']
        data["arg"]=[]

        for key in self.temp1:
            data['arg'].append(self.temp1[key].get());

        self.client.sent(data)
        self.destroy();
        return
