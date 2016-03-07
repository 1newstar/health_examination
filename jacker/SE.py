#__coding:utf-8__
#!/usr/bin/python
# File Name: SE.py
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2016年03月06日 星期日 09时14分00秒
#########################################################################
import sys
import os
import re
reload(sys)
sys.setdefaultencoding('utf8')
#确保Helexam为单例
class Single_Helexam(object):
    def __new__(cls,*args,**kw):
        if not hasattr(cls,'_instance'):
            orig=super(Single_Helexam,cls)
            cls._instance = orig.__new__(cls,*args,**kw)
        return cls._instance
class Helexam(Single_Helexam):
    __slots__=['server_type','Run_Exam']
    def __init__(self,server_type):
        self.server_type=server_type
    def Run_Exam(self):
        dict_type={'1':u'AP','2':u'DB'}
        #print u'通用方法'
        #执行 information.sh
        head1=os.popen('head -1 ../config/proc_user_cnt.conf')
        head1_contents=head1.read()
            #re.sub('HOST_TYPE=\.*\s','HOST_TYPE=%s\s'%dict_type[],head1_contents)
        host_type=re.search('HOST_TYPE=(.*?) ',head1_contents).group(1)
        os.system("sed -i 's#=%s#=%s#g' ../config/proc_user_cnt.conf"%(host_type,dict_type[self.server_type]))
            #os.system('/bin/sh ../script/ap_db.sh')
            #执行 nmon的crontab
            #执行 get Ap_status
        try:
            os.system("/bin/sh ../script/ap_db.sh")
        except:
            print u'体检任务执行失败！'
            #执行 nmon的crontab
            #执行 get DB_status

# START MAIN
if __name__=='__main__':
    stats=[]
    dict_type={'1':u'AP','2':u'DB'}
    while len(stats)!=2:
        print u'请选择需要检查的服务器类型: (1:应用服务器或2:数据库服务器) \n退出: e\n'
        print stats
        server_type = raw_input()
        if server_type == 'e' :
            sys.exit()
        elif server_type not in dict_type:
            print u'输入错误，请输入1或2选择服务器类型!\n'
            continue
        else:
            stats.append(server_type)

        while True:
            oracle_syspwd=raw_input(u'请输入oracle数据库sys用户密码\n r返回,e退出\n')
            if oracle_syspwd=='r':
                stats.pop()
                break
            elif oracle_syspwd=='e':
                sys.exit()
            else:
                if server_type=='2':
                    try:
                        #os.system("su - oracle -c 'sqlplus sys/%s@topprod as sysdba'"%oracle_syspwd)
                        os.system("su - oracle -c 'sqlplus sys/%s@topprod as sysdba'<<EOF exit EOF"%oracle_syspwd)
                        head1=os.popen("sed -n '2p' ../config/proc_user_cnt.conf")
                        head1_contents=head1.read()
                    #re.sub('HOST_TYPE=\.*\s','HOST_TYPE=%s\s'%dict_type[],head1_contents)
                        passwd=re.search('SYS_PASSWD=(.*?) ',a).group(1)
                        os.system("sed -i 's#=%s#=%s#g' ../config/proc_user_cnt.conf"%(passwd,oracle_syspwd))
                    except:
                        print u'密码错误，请重新输入！\n'
                        continue
                stats.append(oracle_syspwd)
                break
#        while True:
#            list_he_cycle=['i','1','7','30']
#            he_cycle=raw_input(u' 请输入体检周期 当前运行状态: r 检测一天: 1 检测一周: 7 \
#                    检测一月: 30\n 返回服务器类型选择: r \n 退出: e\n')
#            if he_cycle=='r':
#                break
#            elif he_cycle=='e':
#                sys.exit()
#            elif he_cycle not in list_he_cycle:
#                print u'体检周期选择错误\n'
#            else:
#                stats.append(he_cycle)
#                break
    #开始run体检脚本
    exam=Helexam(stats[0])
    exam.Run_Exam()
    #设置nmon的执行时间及执行间隔，暂时还没理好
    os.system("echo  '0 0 * * * ../script/nmon -r -d -m ../log -s 60 -c 1440 -F `hostname`__`date +'%Y%m%d'`.nmon 2>&1'  >> /var/spool/cron/jack")



        
        

