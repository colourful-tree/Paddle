from mpi4py import MPI
import ps_pb2 as pslib


class FileSystem(object):
    def __init__(self, fs_type="afs",
                 uri="afs://tianqi.afs.baidu.com:9902",
                 user=None,
                 passwd=None,
                 hadoop_bin="",
                 afs_conf=None):
        assert user != None
        assert passwd != None
        assert hadoop_bin != None
        self.fs_client = pslib.FsClientParameter()
        self.fs_client.uri = uri
        self.fs_client.user = user
        self.fs_client.passwd = passwd
        self.fs_client.hadoop_bin = hadoop_bin

    def get_desc(self):
        return self.fs_client


class MPIHelper(object):
    def __init__(self):
        self.comm = MPI.COMM_WORLD

    def get_rank(self):
        return self.comm.Get_rank()

    def get_size(self):
        return self.comm.Get_size()

    def get_ip(self):
        import socket
        local_ip = socket.gethostbyname(socket.gethostname())
        return local_ip

    def get_hostname(self):
        import socket
        return socket.gethostname()
    
        
