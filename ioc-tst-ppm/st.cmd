#!../../ads-ioc/bin/rhel7-x86_64/adsIoc

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

epicsEnvSet("MOTOR_PORT",     "PLC_ADS")
epicsEnvSet("PREFIX",        "TST:PPM:")
epicsEnvSet("ECM_NUMAXES",   "1")
epicsEnvSet("NUMAXES",       "1")

EthercatMCCreateController("$(MOTOR_PORT)", "$(ASYN_PORT)", "$(NUMAXES)", "200", "1000")

#define ASYN_TRACE_ERROR     0x0001
#define ASYN_TRACEIO_DEVICE  0x0002
#define ASYN_TRACEIO_FILTER  0x0004
#define ASYN_TRACEIO_DRIVER  0x0008
#define ASYN_TRACE_FLOW      0x0010
#define ASYN_TRACE_WARNING   0x0020
#define ASYN_TRACE_INFO      0x0040
asynSetTraceMask("$(ASYN_PORT)", -1, 0x41)

#define ASYN_TRACEIO_NODATA 0x0000
#define ASYN_TRACEIO_ASCII  0x0001
#define ASYN_TRACEIO_ESCAPE 0x0002
#define ASYN_TRACEIO_HEX    0x0004
asynSetTraceIOMask("$(ASYN_PORT)", -1, 2)

#define ASYN_TRACEINFO_TIME 0x0001
#define ASYN_TRACEINFO_PORT 0x0002
#define ASYN_TRACEINFO_SOURCE 0x0004
#define ASYN_TRACEINFO_THREAD 0x0008
asynSetTraceInfoMask("$(ASYN_PORT)", -1, 5)

#define AMPLIFIER_ON_FLAG_CREATE_AXIS  1
#define AMPLIFIER_ON_FLAG_WHEN_HOMING  2
#define AMPLIFIER_ON_FLAG_USING_CNEN   4

epicsEnvSet("AXIS_NO",         "1")
epicsEnvSet("MOTOR_PREFIX",    "TST:PPM:")
epicsEnvSet("MOTOR_NAME",      "MMS:Y")
epicsEnvSet("DESC",            "PPM_Y")
epicsEnvSet("EGU",             "mm")
epicsEnvSet("PREC",            "3")
epicsEnvSet("AXISCONFIG",      "")
epicsEnvSet("ECAXISFIELDINIT", "")
epicsEnvSet("AMPLIFIER_FLAGS", "0")

EthercatMCCreateAxis("$(MOTOR_PORT)", "$(AXIS_NO)", "$(AMPLIFIER_FLAGS)", "$(AXISCONFIG)")
dbLoadRecords("EthercatMC.template", "PREFIX=$(MOTOR_PREFIX), MOTOR_NAME=$(MOTOR_NAME), R=$(MOTOR_NAME)-, MOTOR_PORT=$(MOTOR_PORT), ASYN_PORT=$(ASYN_PORT), AXIS_NO=$(AXIS_NO), DESC=$(DESC), PREC=$(PREC) $(ECAXISFIELDINIT)")
dbLoadRecords("EthercatMCreadback.template", "PREFIX=$(MOTOR_PREFIX), MOTOR_NAME=$(MOTOR_NAME), R=$(MOTOR_NAME)-, MOTOR_PORT=$(MOTOR_PORT), ASYN_PORT=$(ASYN_PORT), AXIS_NO=$(AXIS_NO), DESC=$(DESC), PREC=$(PREC) ")
dbLoadRecords("EthercatMCdebug.template", "PREFIX=$(MOTOR_PREFIX), MOTOR_NAME=$(MOTOR_NAME), MOTOR_PORT=$(MOTOR_PORT), AXIS_NO=$(AXIS_NO), PREC=3")

cd "$(LOCAL)"

dbLoadRecords("MicroTestStandPPM.db", "PORT=$(ASYN_PORT)")

cd "$(TOP)"

dbLoadRecords("db/iocSoft.db", "IOC=IOC:TST:PPM:" )
dbLoadRecords("db/save_restoreStatus.db", "P=IOC:TST:PPM:" )

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
