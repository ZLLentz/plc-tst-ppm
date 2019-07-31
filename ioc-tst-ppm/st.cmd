#!../../../bin/rhel7-x86_64/adsIoc

< envPaths
epicsEnvSet("IOCNAME", "MicroTestStandPPM" )
epicsEnvSet("ENGINEER", "zlentz" )
epicsEnvSet("LOCATION", "IOC:TST:PPM:" )
epicsEnvSet("IOCSH_PS1", "$(IOCNAME)> " )

cd "$(TOP)"

# Run common startup commands for linux soft IOC's
< /reg/d/iocCommon/All/pre_linux.cmd

# Register all support components
dbLoadDatabase("dbd/adsIoc.dbd")
adsIoc_registerRecordDeviceDriver(pdbbase)

cd "$(TOP)/db"

epicsEnvSet("ASYN_PORT",     "ASYN_PLC")
epicsEnvSet("IPADDR",        "172.21.148.185")
epicsEnvSet("AMSID",         "172.21.148.185.1.1")
epicsEnvSet("IPPORT",        "851")

adsAsynPortDriverConfigure("$(ASYN_PORT)","$(IPADDR)","$(AMSID)","$(IPPORT)", 1000, 0, 0, 50, 100, 1000, 0)

S")

epicsEnvSet("ASYN_PORT",     "ASYN_PLC")
epicsEnvSet("PREFIX",        "TST:PPM:")
epicsEnvSet("ECM_NUMAXES",   "1")
epicsEnvSet("NUMAXES",       "1")

#TODO stopped here

dbLoadRecords("MicroTestStandPPM.db", "")

cd "$(TOP)"

dbLoadRecords("db/iocAdmin.db", "P=IOC:TST:PPM:,IOC=IOC:TST:PPM:" )
dbLoadRecords("db/save_restoreStatus.db", "P=IOC:TST:PPM:,IOC=MicroTestStandPPM" )

# Setup autosave
set_savefile_path( "$(IOC_DATA)/$(IOC)/autosave" )
set_requestfile_path( "$(TOP)/autosave" )
save_restoreSet_status_prefix( "IOC:TST:PPM:" )
save_restoreSet_IncompleteSetsOk( 1 )
save_restoreSet_DatedBackupFiles( 1 )
set_pass0_restoreFile( "$(IOC).sav" )
set_pass1_restoreFile( "$(IOC).sav" )

# Initialize the IOC and start processing records
iocInit()

# Start autosave backups
create_monitor_set( "$(IOC).req", 5, "" )

# All IOCs should dump some common info after initial startup.
< /reg/d/iocCommon/All/post_linux.cmd
