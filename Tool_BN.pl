#!/usr/bin/perl -w

use strict;

#golbal variable
my $dir_log="/var/opt/hp93000/system_monitor/em360/logs";
my $dir_target="/var/opt/gpd_etl_service/data/processing";
my $dir_customer;

#check the input file exsit or not
#Usage
my @source_files=glob "$ARGV[0]/*.tar.gz.enc";

if($#ARGV==-1 || $ARGV[0]=~ /--help/i )
{
   print "Usage:\nTool_1   [option] \n"."[option] "."  The input file path\n";
   exit;
}
else
{  
   if($#source_files!=-1)
     {
         $dir_customer=$ARGV[0];
         #print"$dir_customer\n";
     }
   else
     {
         print"ERROR:The input file is not exsit please check!\n";
         print"Try '--help'\n";
         exit;
     }
}
my $source_file;
foreach $source_file(@source_files)
{
    print"$source_file\n";
    my $rev_str=reverse($source_file);
    my $sub_str=substr("$rev_str",4);
    my $outfile_name=reverse($sub_str);
    #print"$rev_str\n";

    my $re_opt;
    #decryption
    $re_opt=system("openssl enc -d -rc4 -k adnAc1h^fgf\%gs -in $source_file -out $outfile_name 1>./shellopt 2>./shellopt");
    if(!$re_opt)
    {
        print"SUCCESS:the file has been decrypted!\n";
    }
    else
    {
        print"FAILURE: decryption failure!\n";
        unlink "./shellopt";
        exit;
    }

    #unzip the files
    $re_opt=system("tar -xf $outfile_name -C $dir_customer 1>./shellopt 2>./shellopt");
    if(!$re_opt)
    {
        print"SUCCESS:the file has been unpackaged!\n";
    }
    else
    {
        print"FAILURE: unpackage failure!\n";
        unlink "./shellopt";
        unlink "$outfile_name";
        exit;
    }

    #sort and move the file
    my @dir_file=glob "$dir_customer/$dir_log/*";
    my $dir_file;
    #print"The total file number: $#dir_file\n";
    if($#dir_file==-1)
    {
        print"No file to move !";
        system("rm -rf $dir_customer/var 1>./shellopt 2>./shellopt");
        unlink "./shellopt";
        unlink "$outfile_name";
        exit;
    }
    else
    {
        foreach $dir_file(@dir_file)
        {   
            $re_opt=system("mv $dir_file  $dir_target  1>./shellopt 2>./shellopt");
            if($re_opt)
            {
                 print"FAILURE:move the file failure,or can't find the target directory!\n";
                 system("rm -rf $dir_customer/var 1>./shellopt 2>./shellopt");
                 unlink "./shellopt";
                 unlink "$outfile_name";
                 exit;
            }
        }
    }
    print"SUCCESS:the files has been moved!\n";
    #remove the decryted and unpackaged files
    $re_opt=system("rm -rf $outfile_name $dir_customer/var ./shellopt 1>./shellopt 2>./shellopt");
    unlink "./shellopt";
    print"SUCCESS:all the operation has been compeleted!\nDONE!\n";

}
