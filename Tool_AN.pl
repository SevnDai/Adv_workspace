#!/usr/bin/perl -w

use strict;
use Sys::Hostname;

#golbal variable
my $dir_log="/var/opt/hp93000/system_monitor/em360/logs";
my @suffix=qw(.log .gz);
my $dir_customer;

my $re_opt;
my $suffix;
my @tar_arg;
my $tar_arg_index=0;
foreach $suffix (@suffix)
{
    $tar_arg[$tar_arg_index]="$dir_log/*$suffix ";
    $tar_arg_index++;
}
#check the input files exsit or not 
my @found_files;
my $found_files_index=0;
my $tar_arg_files;
foreach $tar_arg_files (@tar_arg)
{
    $re_opt=system("find $tar_arg_files 1>./shellopt 2>./shellopt");
    if(!$re_opt)
    {
        print "The source files exsit!\n";
        $found_files[$found_files_index]=$tar_arg_files; 
        $found_files_index++;
    } 
}
if($#found_files==-1)
{
    print "FAILURE:Can't find the source file,please check!\n";
    unlink "./shellopt";
    exit;
}
#check the output file exsit or not
#Usage
if($#ARGV==-1 || $ARGV[0]=~ /--help/i)
{
   print "Usage:\nTool_1   [option] \n"."[option] "."  The output directory path\n";
   exit;
}
else
{  
   if(-e $ARGV[0])
     {
         $dir_customer=$ARGV[0];
         #print"$dir_customer\n";
     }
   else
     {
         print"ERROR:The output directory is not exsit please check!\n";
         print"Try '--help'\n";
         unlink "./shellopt";
         exit;
     }
}
#generate the packaged file name
my $host=hostname();
my($sec,$min,$hour,$day,$mon,$year)=localtime(time);
my $datetime=sprintf("%d%02d%02d%02d%02d%02d",$year+1900,$mon+1,$day,$hour,$min,$sec);
my $file_name="$host"."_"."$datetime";
#print"$file_name";

#pack up the file/files
my $zip_filename="$file_name".".tar.gz";
#print"$zip_filename";
$re_opt=system("tar -cPf $dir_log/$zip_filename @found_files 1>./shellopt 2>./shellopt");
if(!$re_opt)
{		
   print"SUCCESS:the file has been packaged!\n";
}
else
{
   print"FAILURE:packaging failure!\n";
   unlink "./shellopt";
   exit;
} 
#Encrypt the package
my $encrypted_filename="$zip_filename".".enc";
$re_opt=system("openssl enc -e -rc4 -k adnAc1h^fgf\%gs -in $dir_log/$zip_filename -out $dir_log/$encrypted_filename 1>./shellopt 2>./shellopt");
if(!$re_opt)
{
   print"SUCCESS:the package has been encrypted!\n";
}
else
{
   print"FAILURE:encryption failure!\n";
   unlink "./shellopt";
   exit;
}

#move the encrypted package
$re_opt=system("mv $dir_log/$encrypted_filename $dir_customer 1>./shellopt 2>./shellopt");
if(!$re_opt)
{
   print"SUCCESS:the encrypted package has been moved!\n";
}
else
{
   print"FAILURE:move failure!\n";
   unlink "./shellopt";
   exit;
}

#delete the package and original files 
$re_opt=system("rm @found_files  ./shellopt 1>./shellopt 2>./shellopt");
if(!$re_opt)
{
   unlink"$dir_log/$zip_filename";
   print"SUCCESS:the packaged file and original files  has been removed!\n";
   print"SUCCESS:all the operation has been compeleted!\nDONE!\n";
}
else
{
   print"FAILURE:remove failure!\n";
   unlink "./shellopt";
   exit;
}
