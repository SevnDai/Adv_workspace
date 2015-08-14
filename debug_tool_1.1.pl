#!/usr/bin/perl -w

use strict;
use Sys::Hostname;

#version
my $tool_version="1.0.0";
#golbal variable
my $server_log_dir_1="/tmp/gpd_etl_service.log*";
my $server_log_dir_2="/tmp/gpd_server_guard.log*";
my $server_log_dir_3="/tmp/lic_chk_set.*";
my $server_hn_dir_1="/var/opt/gpd_etl_service/data/done/";
my $server_hn_dir_2="/var/opt/gpd_etl_service/data/error/";
my $server_hn_dir_3="/var/opt/gpd_etl_service/data/processing/";

my $client_log_dir_1="/var/opt/em360/log/*";
my $client_log_dir_2="/var/opt/tfi/log/*";
my $client_soc_dir_1="/var/opt/hp93000/soc/calibration/std__*";
my $client_soc_dir_2="/var/opt/hp93000/soc/calibration/rf/*";
my $client_soc_dir_3="/var/opt/hp93000/soc/tracecal/*";

#generate the packaged file name
my $host=hostname();
my($sec,$min,$hour,$day,$mon,$year)=localtime(time);
my $datetime=sprintf("%d%02d%02d%02d%02d%02d",$year+1900,$mon+1,$day,$hour,$min,$sec);
my $file_name="$host"."_"."$datetime"."debug_mesg_files.tar.gz";

mkdir './debug',0755 or warn "can't make debug directory:$!\n";
#option
my $re_opt;
if($#ARGV==-1 || $#ARGV==0 ||$#ARGV==1)
{   &tool_usage;}
elsif($ARGV[0]=~/-m\z/ && $ARGV[1]=~/server\z/)
{
    if($ARGV[2]=~/-a\z|-lfd\z|-ldf\z|-fld\z|-fdl\z|-dlf\z|-dfl\z/)
    {
	if($#ARGV>2)
	{   &tool_usage;}
	else
	{
	    my @re_allS=&getS_all_files;
	    if($#re_allS!=-1)
	    {
	        $re_opt=system("tar -cf ./$file_name  @re_allS 1>./shellopt 2>./shellopt");
     	        &pt_mesg($re_opt);
	    }
	    else
	    {   &pt_nf_mesg;}
	}
    }
    elsif($ARGV[2]=~/-ld\z|-dl\z/)
    {
	if($#ARGV>2)
	{   &tool_usage;}
	else
	{
	    my @re_log=&getS_log_files;
	    my @re_db=&getS_db_files;
	    my @merg_logdb=(@re_log,@re_db);
	    #print"$#merg_logdb";
	    if($#merg_logdb!=-1)
	    {
	        $re_opt=system("tar -cf ./$file_name @merg_logdb 1>./shellopt 2>./shellopt");
     	        &pt_mesg($re_opt);
	    }
	    else
	    {
	        unlink "shellopt";
	        &pt_nf_mesg;
	    }
	}
    }
    elsif($ARGV[2]=~/-lf\z|-fl\z/)
    {
	if($#ARGV==2)
	{   &tool_usage;}
	else
	{
	    my @re_log=&getS_log_files;
	    my @re_hn=&getS_hn_files;
	    my @merg_loghn=(@re_log,@re_hn);
	    if($#merg_loghn!=-1)
	    {
	        $re_opt=system("tar -cf ./$file_name  @merg_loghn 1>./shellopt 2>./shellopt");
     	        &pt_mesg($re_opt);
	    }
	    else
	    {   &pt_nf_mesg;}
	}
    }
    elsif($ARGV[2]=~/-df\z|-fd\z/)
    {
	if($#ARGV==2)
	{   &tool_usage;}
	else
	{
	    my @re_db=&getS_db_files;
	    my @re_hn=&getS_hn_files;
	    #print"@re_hn\n";
	    my @merg_dbhn=(@re_db,@re_hn);
	    if($#merg_dbhn!=-1)
	    {
	        $re_opt=system("tar -cf ./$file_name @merg_dbhn 1>./shellopt 2>./shellopt");
     	        &pt_mesg($re_opt);
	    }
	    else
	    {
		unlink"shellopt";
		&pt_nf_mesg;
	    }
	}
    }
    elsif($ARGV[2]=~/-l\z/)
    {
	if($#ARGV>2)
	{   &tool_usage;}
	else
	{
	    my @re_log=&getS_log_files;
	    if($#re_log!=-1)
	    {
	        $re_opt=system("tar -cf ./$file_name  @re_log 1>./shellopt 2>./shellopt");
     	        &pt_mesg($re_opt);
	    }
	    else
	    {   &pt_nf_mesg;}
	}
    }
    elsif($ARGV[2]=~/-d\z/)
    {if($#ARGV>2)
	{   &tool_usage;}
	else
	{
	    my @re_db= &getS_db_files;
            if($#re_db!=-1)
 	    {
	        $re_opt=system("tar -cf ./$file_name  @re_db 1>./shellopt 2>./shellopt");
	        &pt_mesg($re_opt);
	    }
	    else
	    {   &pt_nf_mesg;}
	}
    }
    elsif($ARGV[2]=~/-f\z/)
    {
	if($#ARGV==2)
	{   &tool_usage;}
	else
	{
	    my @re_hn=&getS_hn_files;
	    #print"@re_hn\n";
	    if($#re_hn!=-1)
 	    {
	        $re_opt=system("tar -cf ./$file_name  @re_hn 1>./shellopt 2>./shellopt");
	        &pt_mesg($re_opt);
	    }
	    else
	    {   &pt_nf_mesg;}
	}
    }
    else
    {   &tool_usage;}
}
elsif($ARGV[0]=~/-m\z/ && $ARGV[1]=~/tester\z/)
{
    if($ARGV[2]=~/-a\z|-lc\z|-cl\z/)
    {
	if($#ARGV>2)
	{   &tool_usage;}
	else
	{
	    my @re_allC=&getC_all_files;
	    if($#re_allC!=-1)
	    {
	        $re_opt=system("tar -cf ./$file_name  @re_allC 1>./shellopt 2>./shellopt");
     	        &pt_mesg($re_opt);
	    }
	    else
	    {   &pt_nf_mesg;}
	}
    }
    elsif($ARGV[2]=~/-l\z/)
    {
	if($#ARGV>2)
	{   &tool_usage;}
	else
	{
	    my @re_log=&getC_log_files;
	    if($#re_log!=-1)
	    {
	        $re_opt=system("tar -cf ./$file_name  @re_log 1>./shellopt 2>./shellopt");
     	        &pt_mesg($re_opt);
	    }
	    else
	    {   &pt_nf_mesg;}
	}
    }
    elsif($ARGV[2]=~/-c\z/)
    {
	if($#ARGV>2)
	{   &tool_usage;}
	else
	{
            my @re_soc= &getC_soc_files;
            #print"@re_soc";
	    if($#re_soc!=-1)
	    {
                $re_opt=system("tar -cf ./$file_name  @re_soc 1>./shellopt 2>./shellopt");
     	        &pt_mesg($re_opt);
	    }
	    else
	    {   &pt_nf_mesg;}
	}
    }
    else
    {   &tool_usage;}
}
else
{   &tool_usage;}
#print not found message
sub pt_nf_mesg
{
    print"FAILURE:No file found\n";
    print"WARNNING: Make sure that you are using correct option\n";
    system("rm -rf ./debug");
    exit;
}
#print message
sub pt_mesg
{
       if($_[0])
        {
	    print"FAILURE:Collect the files failure!\n";
	    system("rm -rf ./debug");
	    unlink "shellopt";exit;
        }
	else
	{
	    print"SUCCESS:Collect the files success!\n";
	    system("rm -rf ./debug");
	    unlink "shellopt";exit;
	}
}
#usage
sub tool_usage
{
    print"Version	:	$tool_version\n";
    print"Usage:\n Debug_tool [option] [option]\n [option]:\n";
    print" -m [server/tester]	:	Debug on server or tester\n server\n";
    print" -a get all files\n -l get log files\n -d get DB files\n -f [-ALL/hostname]	:	Get data of all testers or some testers with hostname specified\n client\n";
    print" -a get all files\n -l get log files\n -c get soc files\n";
    print"Try -help\n";exit;
}

#get server all files
sub getS_all_files
{
    my @re_log=&getS_log_files;
    my @re_db=&getS_db_files;
    my @re_hn= &getS_hn_files;
    my @allS_files=(@re_log,@re_db,@re_hn);
    return @allS_files;
}
#get server log files
sub getS_log_files
{
    my @log_arr_1=glob $server_log_dir_1;
    my @log_arr_2=glob $server_log_dir_2;
    my @log_arr_3=glob $server_log_dir_3;
    my @all_log=(@log_arr_1,@log_arr_2,@log_arr_3);
    if($#all_log!=-1)
    {
	mkdir './debug/log',0755 or warn "can't make cal directory:$!\n";
	system("mv @all_log ./debug/log 1>./shellopt 2>./shellopt");
	my @zip_dir_files=glob "./debug/log/*";
	return @zip_dir_files;
    }
    else
    {   return @all_log;}
}
#get server db files
sub getS_db_files
{
    $re_opt=system("mysqldump -uroot -pem93k2015 -R endurance >/tmp/endurance.sql 1>./shellopt 2>./shellopt");
    if($re_opt)
    {
	print"FAILURE:Can't collect the database files\n";
	my @empty;return @empty;
    } 
    else
    {
	print"SUCCESS:Collected the database files\n";
	mkdir './debug/database',0755 or warn "can't make database directory:$!\n";
	system("mv /tmp/endurance.sql ./debug/database 1>./shellopt 2>./shellopt");
	my @zip_dir_files=glob "./debug/database/*";
	return @zip_dir_files;
    }
}
#get server  client files
sub getS_hn_files
{	
    my @all_hn_files;
    my @hn_arr1;
    my @hn_arr2;
    my @hn_arr3;
    mkdir './debug/data',0755 or warn "can't make data directory:$!\n";
    if($ARGV[2]=~/-a|-lfd|-ldf|-fld|-fdl|-dlf|-dfl/ || $ARGV[3]=~/-ALL/)
    {
	{
	   @hn_arr1=glob "$server_hn_dir_1/*";
	   if($#hn_arr1!=-1)
	   {
		mkdir './debug/data/down',0755 or warn "can't make down directory:$!\n";
		system("mv @hn_arr1 ./debug/data/down 1>./shellopt 2>./shellopt");
	   }
	   @hn_arr2=glob "$server_hn_dir_2/*";
	   if($#hn_arr2!=-1)
	   {
		mkdir './debug/data/error',0755 or warn "can't make error directory:$!\n";
		system("mv @hn_arr2 ./debug/data/error 1>./shellopt 2>./shellopt");
	   }
	   @hn_arr3=glob "$server_hn_dir_3/*";
	   if($#hn_arr3!=-1)
	   {
		mkdir './debug/data/processing',0755 or warn "can't make processing directory:$!\n";
		$re_opt=system("mv @hn_arr3 ./debug/data/processing 1>./shellopt 2>./shellopt");
	   }
	}
    }
    else
    {
	foreach my $hostname(@ARGV)
	{
	    if($hostname eq($ARGV[0]) || $hostname eq($ARGV[1]) || $hostname eq($ARGV[2]))
	    {   next;}
	    else
	    {
	        @hn_arr1=glob "$server_hn_dir_1/$hostname*";
		 if($#hn_arr1!=-1)
		{
			mkdir './debug/data/down',0755 or warn "can't make down directory:$!\n";
			system("mv @hn_arr1 ./debug/data/down 1>./shellopt 2>./shellopt");
		}
	        @hn_arr2=glob "$server_hn_dir_2/$hostname*";
		if($#hn_arr2!=-1)
		{
			mkdir './debug/data/error',0755 or warn "can't make error directory:$!\n";
			system("mv @hn_arr2 ./debug/data/error 1>./shellopt 2>./shellopt");
		}
	        @hn_arr3=glob "$server_hn_dir_3/$hostname*";
		if($#hn_arr3!=-1)
		{
			mkdir './debug/data/processing',0755 or warn "can't make processing directory:$!\n";
			$re_opt=system("mv @hn_arr3 ./debug/data/processing 1>./shellopt 2>./shellopt");
		}
	    }
	    if($#hn_arr1==-1 && $#hn_arr2==-1 && $#hn_arr3==-1)
	    {   print"WARNNING:Can't find the $hostname ,make sure that your option are correct\n";}
	}
    }
    my @zip_dir_down=glob "./debug/data/down/*";
    my @zip_dir_error=glob "./debug/data/error/*";
    my @zip_dir_processing=glob "./debug/data/processing/*";
    @all_hn_files=(@zip_dir_down,@zip_dir_error,@zip_dir_processing);
    return @all_hn_files;
}

#get client all files
sub getC_all_files
{
    my @re_log= &getC_log_files;
    my @re_soc=&getC_soc_files;
    my @allC_files=(@re_log,@re_soc);
    return @allC_files;
}
#get client log files
sub getC_log_files
{ 
    my @log_arr_1=glob $client_log_dir_1;
    my @log_arr_2=glob $client_log_dir_2;
    my @all_log=(@log_arr_1,@log_arr_2);
    if($#all_log!=-1)
    {
	mkdir './debug/log',0755 or warn "can't make cal directory:$!\n";
	system("mv @all_log ./debug/log 1>./shellopt 2>./shellopt");
	my @zip_dir_files=glob "./debug/log/*";
	return @zip_dir_files;
    }
    else
    {   return @all_log;}
}
#get client soc files
sub getC_soc_files
{
    my @soc_arr_1=glob $client_soc_dir_1;
    my @soc_arr_2=glob $client_soc_dir_2;
    my @soc_arr_3=glob $client_soc_dir_3;
    my @all_soc=(@soc_arr_1,@soc_arr_2,@soc_arr_3);
    if($#all_soc!=-1)
    {
	mkdir './debug/cal',0755 or warn "can't make cal directory:$!\n";
	system("mv @all_soc ./debug/cal 1>./shellopt 2>./shellopt");
	my @zip_dir_files=glob "./debug/cal/*";
	return @zip_dir_files;
    }
    else
    {   return @all_soc;}
}
