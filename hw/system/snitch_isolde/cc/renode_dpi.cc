// Copyleft
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

#include "Vtop__Dpi.h"
#include "Vtop.h"
#include <map>

typedef std::map<long long, long long> storage_type;


storage_type g_storage;
storage_type::iterator g_read_it;


    // DPI import at /home/uic52463/hdd2/isolde-project/hwpe-tb/renode_memory/hdl/imports/renode_pkg.sv:39:32
    extern void renodeDPIConnect(int receiverPort, int senderPort, const char* address){
        printf("\nrenodeDPIConnect\n");
    }
    // DPI import at /home/uic52463/hdd2/isolde-project/hwpe-tb/renode_memory/hdl/imports/renode_pkg.sv:45:32
    extern void renodeDPIDisconnect(){
        printf("\renodeDPIDisconnect\n");
    }
    // DPI import at /home/uic52463/hdd2/isolde-project/hwpe-tb/renode_memory/hdl/imports/renode_pkg.sv:47:31
    extern svBit renodeDPIIsConnected(){
        printf("\renodeDPIIsConnected\n");
        return 1;
    }
    // DPI import at /home/uic52463/hdd2/isolde-project/hwpe-tb/renode_memory/hdl/imports/renode_pkg.sv:49:32
    extern void renodeDPILog(int logLevel, const char* data){
        printf("\renodeDPILog:%s\n",data);
    }
    // DPI import at /home/uic52463/hdd2/isolde-project/hwpe-tb/renode_memory/hdl/imports/renode_pkg.sv:54:31
    extern svBit renodeDPIReceive(int* action, long long* address, long long* data){
        printf("renodeDPIReceive: ");
        if(g_read_it != g_storage.end()){
            //printf("read will be performed from initialised address=0x%x", *address)
            *address = g_read_it->first;
            *data    = g_read_it->second;            
        } else {
            printf(" WARNING: reading from un-initialised address=0x%llx\n", *address);
            *data = static_cast<long long>( 0);
        }
        return 1;

    }
    // DPI import at /home/uic52463/hdd2/isolde-project/hwpe-tb/renode_memory/hdl/imports/renode_pkg.sv:60:31
    extern svBit renodeDPISend(int action, long long address, long long data){
        printf("\renodeDPISend\n");
        return 1;
    }
    // DPI import at /home/uic52463/hdd2/isolde-project/hwpe-tb/renode_memory/hdl/imports/renode_pkg.sv:66:31
    extern svBit renodeDPISendToAsync(int action, long long address, long long data){
        printf("\renodeDPISendToAsync, action=%d,address=0x%llx, data=0x%llx\n", action, address,data);
        switch( action){
            default:
                printf("\renodeDPISendToAsync, unknown action=%d, for address=0x%llx, data=0x%llx\n", action, address,data);
                break;
            case 13: // pushWord = 13,
                {
                    storage_type::iterator it = g_storage.find(address);
                    if(it != g_storage.end()){
                        //
                        g_storage[address]=data;
                        printf("updating address=0x%llx with Word=0x%llx\n", address, data);
                    } else {
                        g_storage.insert(std::pair<long long, long long>(address,data));
                        printf("writting at address=0x%llx  Word=0x%llx\n", address, data);
                    }
                    
                }
                break;
            case 29: //pushQuadWord = 29,
                {
                    storage_type::iterator it = g_storage.find(address);
                    if(it != g_storage.end()){
                        //
                        g_storage[address]=data;
                        printf("updating address=0x%llx with QuadWord=0x%llx\n", address, data);
                    } else {
                        g_storage.insert(std::pair<long long, long long>(address,data));
                        printf("writting at address=0x%llx  QuadWord=0x%llx\n", address, data);
                    }

                }
                break;
////////////////////////////////////////////////////
            case 14: //getWord = 14,
                {   
                    g_read_it = g_storage.find(address);
                    if(g_read_it != g_storage.end()){
                        printf("Word read wil from initialised address=0x%llx\n", address);
                    } else {
                        printf("Word read will be performed from un-initialised address=0x%llx\n", address);
                    }
                        
                }
                break;
            case 30: //getQuadWord = 30,
                {
                    g_read_it = g_storage.find(address);
                    if(g_read_it != g_storage.end()){
                        printf("QuadWord read will be performed from initialised address=0x%llx\n", address);
                    } else {
                        printf("QuadWord read will be performed from un-initialised address=0x%llx\n", address);
                    }
                }
                break;
        }



        return 1;
    }


    extern void tb_memory_read(long long addr, int len, const svOpenArrayHandle data){
         printf("\tb_memory_read address=0x%llx, len=0x%x\n", addr,len);

    }
    // DPI import at /ubuntu_20.04/home/ext/isolde-project/snitch/hw/ip/test/src/tb_memory_regbus.sv:29:32
    extern void tb_memory_write(long long addr, int len, const svOpenArrayHandle data, const svOpenArrayHandle strb){
        printf("\tb_memory_write address=0x%llx, len=0x%x\n", addr,len);

    }