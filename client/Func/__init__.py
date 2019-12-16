import tkinter
import operator
from Page.rootcss import deluser
from Page.rootcss import usertorole
from Page.rootcss import userxrole
from Page.rootcss import addrole
from Page.rootcss import delrole
from Page.rootcss import roletoproject
from Page.rootcss import rolexproject
from Page.rootcss import delproject
from Page.rootcss import addproject
from Page.rootcss import projecttoorder
from Page.rootcss import projectxorder
from Page.rootcss import addorder
from Page.rootcss import delorder
from Page.rootcss import addcss
from Page.rootcss import delcss
from Page.rootcss import ordertocss
from Page.rootcss import orderxcss
from Page.rootcss import ordercss
from Page.rootcss import cleancache

def layout(client):
        client.Index.Login.pack_forget();
        client.Index.Reg.pack_forget();
        client.Index.w.pack_forget();
        client.Index.A=tkinter.Frame(client.Index)
        client.Index.A.pack(fill=tkinter.X);
        client.Index.B=tkinter.Frame(client.Index)
        client.Index.B.pack(side=tkinter.LEFT);
        client.Index.C=tkinter.Frame(client.Index)
        client.Index.C.pack(side=tkinter.LEFT);
        client.Index.w=tkinter.Canvas(client.Index.C)
        client.Index.w.pack(side=tkinter.LEFT,fill=tkinter.Y);
        client.Index.w.create_line(100,0,100,300,fill='black' , dash=(4,4));
        tkinter.Label(client.Index.A , text='登录身份：'+ client.Index.username.get()).pack();
        client.Index.update();

def getOrder(client , id):
    data={'obj':'Project','action':'get' ,'user':client.Index.username.get() ,'pid':id }
    client.sent(data)
    return

def P(client , id):
    return lambda x:getOrder(client , id)

def Porder(client , pid ,id):
    return lambda x:getCss(client , pid , id)

def getCss(client , pid , id):
    data={'obj':'Order' , 'action':'get','user':client.Index.username.get() ,'pid':pid,'oid':id };
    client.sent(data)

def addProject (client,data):
    if hasattr (client.Index ,'A'):
        for i in client.Index.projects:
            i.pack_forget();
            client.Index.update();
    else:
        layout(client)
    for i in data['data']:
        button=tkinter.Button(client.Index.B, text=i['name'],width=15)
        button.bind(sequence='<Button-1>',func=P(client , i['id']))
        button.pack()
        client.Index.projects.append(button)
    return

def addOrder(client , data):
    pid=data['pid']
    client.Index.C.pack_forget();
    client.Index.C=tkinter.Frame(client.Index)
    client.Index.C.pack(side=tkinter.LEFT)
    client.Index.w=tkinter.Canvas(client.Index.C)
    client.Index.w.pack(side=tkinter.LEFT,fill=tkinter.Y);
    client.Index.w.create_line(100,0,100,300,fill='black' , dash=(4,4));

    client.Index.update();
    for i in data['data']:
        c=tkinter.Button(client.Index.C, text=i['name'],width=15)
        c.bind(sequence='<Button-1>',func=Porder(client , pid , i['id']))
        c.pack()
    return


def css (client , data):
    if  operator.eq(data['data']['title'],'del-user'):
        delu=deluser.new(client , data);
        client.Index.wait_window(delu);
    elif operator.eq(data['data']['title'],'user-to-role'):
        client.Index.wait_window(usertorole.new(client,data))
    elif operator.eq(data['data']['title'] , 'user-x-role'):
        client.Index.wait_window(userxrole.new(client,data))
    elif operator.eq(data['data']['title'] , 'del-role'):
        client.Index.wait_window(delrole.new(client,data))
    elif operator.eq(data['data']['title'] , 'add-role'):
        client.Index.wait_window(addrole.new(client,data))
    elif operator.eq(data['data']['title'] ,'role-to-project'):
        client.Index.wait_window(roletoproject.new(client,data))
    elif operator.eq(data['data']['title'] ,'role-x-project'):
        client.Index.wait_window(rolexproject.new(client,data))
    elif operator.eq(data['data']['title'] ,'del-project'):
        client.Index.wait_window(delproject.new(client,data))
    elif operator.eq(data['data']['title'] ,'add-project'):
        client.Index.wait_window(addproject.new(client,data))
    elif operator.eq(data['data']['title'] ,'project-to-order'):
        client.Index.wait_window(projecttoorder.new(client,data))
    elif operator.eq(data['data']['title'] ,'project-x-order'):
        client.Index.wait_window(projectxorder.new(client,data))
    elif operator.eq(data['data']['title'] ,'add-order'):
        client.Index.wait_window(addorder.new(client,data))
    elif operator.eq(data['data']['title'] ,'del-order'):
        client.Index.wait_window(delorder.new(client,data))
    elif operator.eq(data['data']['title'] ,'add-css'):
        client.Index.wait_window(addcss.new(client,data))
    elif operator.eq(data['data']['title'] ,'del-css'):
        client.Index.wait_window(delcss.new(client,data))
    elif operator.eq(data['data']['title'],'order-to-css'):
        client.Index.wait_window(ordertocss.new(client,data))
    elif operator.eq(data['data']['title'], 'order-x-css'):
        client.Index.wait_window(orderxcss.new(client,data))
    elif operator.eq(data['data']['title'], 'cleancache'):
        client.Index.wait_window(cleancache.new(client,data))
    else:
        client.Index.wait_window(ordercss.new(client, data))
    return
