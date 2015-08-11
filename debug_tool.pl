#!/usr/bin/perl -w

use strict;

#golbal variable
my $server_log_dir_1="/tmp/gpd_etl_service.log*";
my $server_log_dir_2="/tmp/gpd_server_guard.log*";
my $server_log_dir_3="/tmp/lic_chk_set.*";
my $server_hn_dir_1="/var/opt/gpd_etl_service/data/done/";
my $server_hn_dir_2="/var/opt/gpd_etl_service/error/";
my $server_hn_dir_3="/var/opt/gpd_etl_service/data/processing/";

my $client_log_dir_1="/var/opt/em360/log/*";
my $client_log_dir_2="/var/opt/tfi/log/*";
my $client_soc_dir_1="/var/opt/hp93000/soc/calibration/std__*";
my $client_soc_dir_2="/var/opt/hp93000/soc/calibration/rf/*";
my $client_soc_dir_3="/var/opt/hp93000/soc/tracecal/*";

my $re_opt;
#

{
    if($ARGV[0]=~/-a|-lc|-laf/i)
    {
        print"all\n";
    }
    elsif($ARGV[0]=~/-ld|-dl/)
    {
	my @re_log=&getS_log_files;
	my @re_db=&getS_db_files;
	my @merg_logdb=(@re_log,@re_db);
	#print"$#merg_logdb";
	if($#merg_logdb!=-1)
	{
	    $re_opt=system("tar -cf ./debug_ms_files.tar.gz  @merg_logdb 1>./shellopt 2>./shellopt");
     	    &pt_mesg($re_opt);
	}
	else
	{
	    print"FAILURE:no file found\n";
	    unlink "shellopt";
	    exit;
	}
    }
    elsif($ARGV[0]=~/-lf|-fl/)
    {
	if($#ARGV==0)
	{   &tool_usage;}
	else
	{
	    my @re_log=&getS_log_files;
	    my @re_hn=&getS_hn_files;
	    my @merg_loghn=(@re_log,@re_hn);
	    if($#merg_loghn!=-1)
	    {
	        $re_opt=system("tar -cf ./debug_ms_files.tar.gz  @merg_loghn 1>./shellopt 2>./shellopt");
     	        &pt_mesg($re_opt);
	    }
	    else
	    {
	        print"FAILURE:no file found\n";
	        exit;
	    }
	}
	
    }
    elsif($ARGV[0]=~/-df|-fd/)
    {
	if($#ARGV==0)
	{   &tool_usage;}
	else
	{
	    my @re_db=&getS_db_files;
	    my @re_hn=&getS_hn_files;
	    #print"@re_hn\n";
	    my @merg_dbhn=(@re_db,@re_hn);
	    if($#merg_dbhn!=-1)
	    {
	        $re_opt=system("tar -cf ./debug_ms_files.tar.gz  @merg_dbhn 1>./shellopt 2>./shellopt");
     	        &pt_mesg($re_opt);
	    }
	    else
	    {
	        print"FAILURE:no file found\n";
		unlink"shellopt";
	        exit;
	    }
	}
	
    }
    elsif($ARGV[0]=~/-l/i)
    {
        
    }
    elsif($ARGV[0]=~/-d/i)
    {
	my @re_db= &getS_db_files;
        if($#re_db!=-1)
 	{
	    $re_opt=system("tar -cf ./debug_ms_files.tar.gz  @re_db 1>./shellopt 2>./shellopt");
	    &pt_mesg($re_opt);
	}
	else
	{
	    print"FAILURE:no file found\n";
            exit;
	}
    }
    elsif($ARGV[0]=~/-f/i)
    {
	if($#ARGV==0)
	{   &tool_usage;}
	else
	{
	    my @re_hn=&getS_hn_files;
	    print"@re_hn\n";
	    if($#re_hn!=-1)
 	    {
	        $re_opt=system("tar -cf ./debug_ms_files.tar.gz  @re_hn 1>./shellopt 2>./shellopt");
	        &pt_mesg($re_opt);
	    }
	    else
	    {
	        print"FAILURE:no file found\n";
                exit;
	    }
	}
    }
    elsif($ARGV[0]=~/-c/i)
    {
        my @re_soc= &getC_soc_files;
        print"@re_soc";
	if($#re_soc!=-1)
	{
            $re_opt=system("tar -cf ./debug_ms_files.tar.gz  @re_soc 1>./shellopt 2>./shellopt");
     	    &pt_mesg($re_opt);
	}
	else
	{
	    print"FAILURE:no file found\n";
	    exit;
	}
    }
    else
    {   &tool_usage;}
}
#print message
sub pt_mesg
{
       if($_[0])
        {
	    print"FAILURE:collect the ms failure!\n";
	    unlink "shellopt";exit;
        }
	else
	{
	    print"SUCCESS:collect the ms sucess!\n";
	    unlink "shellopt";exit;
	}
}
#usage
sub tool_usage
{
    print"Usage:\n Debug_tool [option]\n [option]:\n";
    print" -a: get all files\n -l get log files\n -d get DB files\n -f get client files only server (-f -ALL or hostname)\n -c get client files only client\n";
    print"Try -help\n";exit;
}

#get server all files
sub getS_all_files
{
    my @re_log=&getS_log_files;
    my @re_db=&getS_db_filse;
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
    return @all_log;
}
#get server db files
sub getS_db_files
{
    $re_opt=system("mysqldump -uroot -pem93k2015 -R endurance >/tmp/endurance.sql 1>./shellopt 2>./shellopt");
    if($re_opt)
    {
	print"FAILURE:can't collect the db files\n";
	my @empty;return @empty;
    } 
    else
    {
	print"SUCCESS:collected the db files\n";
        my @all_db=glob "/tmp/endurance.sql";
	return @all_db;
    }
}
#get server  client files
sub getS_hn_files
{	
    my $index=0;
    my @all_hn_files;
    my @hn_arr1;
    my @hn_arr2;
    my @hn_arr3;
    if($ARGV[1]=~/-ALL/)
    {
	@hn_arr1=glob "$server_hn_dir_1/*";
	@hn_arr2=glob "$server_hn_dir_2/*";
	@hn_arr3=glob "$server_hn_dir_3/*";
	@all_hn_files=(@hn_arr1,@hn_arr2,@hn_arr3);
	return @all_hn_files;
    }
    else
    {
	foreach my $hostname(@ARGV)
	{
	    if($hostname eq($ARGV[0]))
	    {   next;}
	    else
	    {
	        @hn_arr1=glob "$server_hn_dir_1/$hostname*";
	        @hn_arr2=glob "$server_hn_dir_2/$hostname*";
	        @hn_arr3=glob "$server_hn_dir_3/$hostname*";
	    }
	    foreach my $hostname_files(@hn_arr1,@hn_arr2,@hn_arr3)
	    {
	        $all_hn_files[$index]=$hostname_files;
	        $index++;
	    }
	}
	return @all_hn_files;
    }
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
    return @all_log;
}
#get client soc files
sub getC_soc_files
{
    my @soc_arr_1=glob $client_soc_dir_1;
    my @soc_arr_2=glob $client_soc_dir_2;
    my @soc_arr_3=glob $client_soc_dir_3;
    my @all_soc=(@soc_arr_1,@soc_arr_2,@soc_arr_3);
    return @all_soc;
}