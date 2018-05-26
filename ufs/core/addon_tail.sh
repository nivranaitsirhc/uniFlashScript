#!/sbin/sh
#	
#	uniFlashScript
#
#	CodRLabworks
#	CodRCA : Christian Arvin
#

. /tmp/backuptool.functions


# INSTALLER.SH AUTOGENERATED DEF.
# _____________________________________________________________________________ <- 80 char
#

# ! AUTOGENERATED BY INSTALLER.SH !
addon_name=null
addon_src_ver=null
addon_app_rev=null

# ! AUTOGENERATED BY INSTALLER.SH !
wipe_list="
"

# ! AUTOGENERATED BY INSTALLER.SH !
list_files() {
cat <<EOF
EOF
}

# Local Functions
# _____________________________________________________________________________ <- 80 char
#

# Initial ui_print Function 
ui_print(){
	echo -n -e "ui_print $1\n" >> /proc/self/fd/$OUTFD
	echo -n -e "ui_print\n" >> /proc/self/fd/$OUTFD
	
	[ -n "$1" ] && file_log "$1"
}

# Cold Log
file_log() {
	[ -n "$1" ] && IN="$1" || read IN
	echo "$(date "+%H:%M:%S") $IN" >> $COLD_TMP
	printf "$IN\n"
}

# local set_perm
set_perm() {
	[[ -n "$1" && -n "$2" && -n "$3" && -n "$4" ]] && {
		chown $1.$2 $4
		chown $1:$2 $4
		chmod $3 $4
	}
}

# ASLIB EXPORTED FUNCTIONS
# _____________________________________________________________________________ <- 80 char
#

# REDIRECT ASLIB LOGGING TO LOCAL LOGGING
LT1=file_log;LT2=file_log;LT3=file_log;LT4=file_log;

# ASLIB.SUB.PRINT_HEADER
print_header(){
	set=0;tmh_init=false;

	while true;do
		eval val='$'TMH${set}
		if [ "$val" == "#" ];then
			ui_print " "
		elif [ -n "$val" ]; then
			ui_print "$val"
		elif [ -z "$val" ]; then
			# ignore the first blank TMH
			[ "$tmh_init" == "true" ] && {
				break
			}
			tmh_init=true
		fi
		set=$((++set))
	done
}

# ASLIB.SUB.IS_MOUNTED
is_mounted() {
	local s
	[ -n "$2" ] && {
		cat /proc/mounts | grep $1 | grep $2, >/dev/null 2>&1
		s=$?
	} || {
		cat /proc/mounts | grep $1            >/dev/null 2>&1
		s=$?
	}
	[ "$s" == "0" ] && \
	$LT3 "I: ASLIB is_mounted: $1 is mounted $2" || \
	$LT3 "I: ASLIB is_mounted: $1 is not mounted"
	
	return $s
}

# ASLIB.SUB.TOOLBOX_MOUNT
toolbox_mount() {
	# default to READ_WRITE
	local RW=rw
	[ ! -z "$2" ] && RW=$2

	local DEV=;
	local POINT=;
	local FS=;
	
	for i in `cat /etc/fstab | grep "$1"`; do
		if [ -z "$DEV" ]; then
			DEV=$i
		elif [ -z "$POINT" ]; then
			POINT=$i
		elif [ -z "$FS" ]; then
			  FS=$i
			break
		fi
	done

	(! is_mounted $1 $RW) && mount -t $FS -o $RW $DEV $POINT               >/dev/null 2>&1
	(! is_mounted $1 $RW) && mount -t $FS -o $RW,remount $DEV $POINT       >/dev/null 2>&1

	DEV=;POINT=;FS=;
	
	for i in `cat /etc/recovery.fstab | grep "$1"`; do
		if [ -z "$POINT" ]; then
			POINT=$i
		elif [ -z "$FS" ]; then
			FS=$i
		elif [ -z "$DEV" ]; then
			DEV=$i
			break
		fi
	done

	if [ "$FS" = "emmc" ];then
		(! is_mounted $1 $RW) && mount -t ext4 -o $RW $DEV $POINT            >/dev/null 2>&1
		(! is_mounted $1 $RW) && mount -t ext4 -o $RW,remount $DEV $POINT    >/dev/null 2>&1
		(! is_mounted $1 $RW) && mount -t f2fs -o $RW $DEV $POINT            >/dev/null 2>&1
		(! is_mounted $1 $RW) && mount -t f2fs -o $RW,remount $DEV $POINT    >/dev/null 2>&1
	else
		(! is_mounted $1 $RW) && mount -t $FS -o $RW $DEV $POINT             >/dev/null 2>&1
		(! is_mounted $1 $RW) && mount -t $FS -o $RW,remount $DEV $POINT     >/dev/null 2>&1
	fi
}

##### ASLIB.SUB.REMOUNT_MOUNTPOINT
remount_mountpoint() {
	$LT2 "I: ASLIB remount_mountpoint: checking $1 $2"
	[ -n "$*" ] && {
		(! is_mounted $1 $2) && mount -o $2,remount $1    >/dev/null 2>&1
		(! is_mounted $1 $2) && mount -o $2,remount $1 $1 >/dev/null 2>&1
		(! is_mounted $1 $2) && toolbox_mount $1          >/dev/null 2>&1
		(! is_mounted $1 $2) && {
			$LT3 "I: ASLIB remount_mountpoint: failed to remount"
			stat=1
		} || {
			$LT3 "I: ASLIB remount_mountpoint: remounted successfully"
			stat=0
		}
		return $stat
	}
}

###### ASLIB.SUB.SET_SYSTEM_FP
set_system_fp() {
	[[ "$(echo ${1} | cut -d / -f 2-2)" != "system" ]] && {
		$LT2 "E: ASLIB set_system_fp: not valid system file input $1"
		$LT3 "W: ASLIB set_system_fp: only system files with full path are accepted"
	}
	
	_sys="$(echo ${1} | cut -d / -f 3-3)"
	
	case $_sys in
		bin|xbin)
			set_perm 0 0 0755 $1
			chmod +x $1
		;;
		vendor)
			_sysv="$(echo ${1} | cut -d / -f 4-4)"
			case $_sysv in
				bin|xbin)
				set_perm 0 0 0755 $1
				chmod +x $1
				;;
				*)
				set_perm 0 0 0655 $1
				;;
			esac
		;;
		*)
			set_perm 0 0 0655 $1
		;;
	esac
}


# Pre-Initialization
# _____________________________________________________________________________ <- 80 char
#

# CREATE A TEMP. PLACEHOLDER FOR LOGGING
COLD_TMP=/tmp/$addon_name.log

# CREATE THE COLD LOG HEADER
[ ! -e $COLD_TMP ] && {
	file_log " "
	file_log "uniFlashScript addon.d logs"
	file_log " "
	file_log "$addon_name"
	file_log "src ver. : $addon_src_ver"
	file_log "src rev. : $addon_app_rev"
}

# CUSTOM UI_PRINT HEADER
# ! LEAVE THIS PART !
TMH0=""
TMH1="#"
# ! BEGIN HEADER HERE !
TMH2=""

# FD FAILSAFE
OUTFD=`ps | grep -v grep | grep -oE "update(.*)" | cut -d" " -f3`

# Initialization
# _____________________________________________________________________________ <- 80 char
#

# CREATE THE DIRECTORY OTA LOG
# by uniFlashScript standard..
[ ! -e /sdcard/logs/ufs/ota ] && {
	file_log "I: $addon_name: creating ota directory"
	install -d /sdcard/logs/ufs/ota
}

# OVIRRIDE C DEF. AND REDIRECT TO SDCARD
C=/sdcard/tmp_ufs_ota

# CREATE TEMP FILE HOLDER
[ ! -e $C ] && mkdir $C

# Main
# _____________________________________________________________________________ <- 80 char
#

case "$1" in
  backup)
	# print_header
	TMH1="backup $addon_name "
	print_header
	
	# Safely Check that SDCARD is mounted
	remount_mountpoint /sdcard rw
	
	# Backup
	file_log "I: $addon_name: backing_up files"
	list_files | while read FILE DUMMY; do
		backup_file $S/"$FILE"
		[ -e $C/system/$FILE ] && {
			file_log "I: $addon_name: success :$C/system/$FILE"
		} || {
			file_log "E: $addon_name: FAILED  :$S/$FILE"
		} 
	done
  ;;
  restore)
	# print_header
	TMH1="restore $addon_name "
	print_header
	
	# Safely Check that SDCARD is mounted
	remount_mountpoint /sdcard rw
	
	file_log "I: $addon_name: wiping files"
	# Wipe files
	for m in $wipe_list;do
		rm -rf /system/$m
		[ -e /system/$m ] && {
			file_log "E: $addon_name: FAILED  :/system/$m"
		} || {
			file_log "I: $addon_name: removed :/system/$m"
		}
	done
	
	# Install
	file_log "I: $addon_name: restoring files"
	list_files | while read FILE REPLACEMENT; do
		R=""
		[ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
		[ -f "$C/$S/$FILE"  ] && (
			restore_file $S/"$FILE" "$R"
			[ -e $S/"$FILE" ] && {
				file_log "I: $addon_name: installed :$S/$FILE"
			} || {
				file_log "E: $addon_name: FAILED    :$S/$FILE"
			}
		)
	done
  ;;
  pre-backup)
	# Stub
  ;;
  post-backup)
	# Stub
  ;;
  pre-restore)
	# Stub
  ;;
  post-restore)
	# print_header
	TMH1="post-restore $addon_name "
	print_header
	
	
	# Setup Correct Permissions
	file_log "I: $addon_name: setting permisions"
	for i in $(list_files); do
		[ -e "$S/$i" ] && {
			set_system_fp "$S/$i"
			chmod 0755 $(dirname "$S/$i") && \
			file_log "I: $addon_name: dir set to 755" || \
			file_log "E: $addon_name: dir chmod 755 failed"
		}
	done
	
	# Remove tmp files
	file_log "I: $addon_name: removing waste $C"
	rm -rf $C
	[ -e $C ] && file_log "I: $addon_name: failed in removing waste $C, just remove it manually."
	
	# FLUSH THE FILE LOG TO THE LOGFILE
	LOG_FILE=/sdcard/logs/ufs/ota/"$addon_name"'_'$(date "+%Y-%m-%d_%H-%M-%S").log
	cat $COLD_TMP > $LOG_FILE
	# remove
	rm -rf $COLD_TMP
  ;;
esac

