#   Copyright (c) 2018 PaddlePaddle Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and

import helper as dist_helper
import sys

class PaddlePSInstance(object):
    def __init__(self, server_worker_mode, proc_per_node):
        self.dh = dist_helper.MPIHelper()
        self._rankid = self.dh.get_rank()
        self._server_worker_mode = server_worker_mode
        self._proc_per_node = proc_per_node
        self._nodes = self.dh.get_size()
        
        self._ip = 0
        self._worker_num = self._nodes * self._proc_per_node / 2
        self._server_num = self._nodes * self._proc_per_node / 2
        self._total_server_worker = self._worker_num + self._server_num
        self._node_type = None #IDLE=-1, WORKER=1, SERVER=0
        self._set_nodetype()
        self._comm = None
        self._split_comm()
        

    def _set_nodetype(self):
        if self._server_worker_mode == 0:
            if self._rankid < self._server_num: 
                self._node_type = 1
            elif self._rankid < self._total_server_worker:
                self._node_type = 0
            else:
                self._node_type = -1
        elif self._server_worker_mode == 1:
            if self._rankid < self._total_server_worker:
                if 0 == self._rankid % self._proc_per_node % 2:
                    self._node_type = 0
                else:
                    self._node_type = 1
            else: 
                self._node_type = -1;
        else:
            self._node_type = -1
            
        #if self._rankid == 0:
            #print "node type: ", self._node_type

    def _split_comm(self):
        if self.is_server():
            self._comm = self.dh.comm.Split(self._node_type)
        elif self.is_worker():
            self._comm = self.dh.comm.Split(self._node_type)
        pass

    def get_worker_index(self):
        if self._server_worker_mode == 0:
            return self._rankid == self.server_num
        else:
            return self._rankid / self._proc_per_node

    def get_server_index(self):
        if self._server_worker_mode == 0:
            return self.rank_id
        else:
            return self.rank_id / self._proc_per_node

    def is_worker(self):
        return self._node_type == 1

    def is_server(self):
        return self._node_type == 0

    def is_first_worker(self):
        return self.is_worker() and 0 == self.get_worker_index()

    def set_ip(self, ip):
        self._ip = ip

    def gather_ips(self):
        self._ips = self.dh.comm.allgather(self._ip)
        return self._ips

    def get_node_cnt(self):
        return self._nodes

    def barrier_all(self):
        self.dh.comm.barrier()

    def barrier_worker(self):
        if self.is_worker():
            self._comm.barrier()
        pass

    def finalize(self):
        self.dh.finalize()
        pass


if __name__ == "__main__":
    instance = PaddlePSInstance(1, 1, 2, 50)
    instance.barrier_all()