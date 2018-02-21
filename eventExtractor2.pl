#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use Time::Local;


# Check the number of args and if they are json files.
my $num_args = $#ARGV + 1;
if($num_args != 1){
	print "Usage: ./readEmail.pl <input_email.json>\n";
	exit;
}
if ($ARGV[0] !~ /^.+?.json$/) {
	print "Please use json files only\n";
	exit;
}

my $input_file = $ARGV[0];
my $output_file = "i_am_here.json";

# Read file into local storage.
open my $email_file, $input_file or die "File operation failed: $!";
my @file_content = <$email_file>;
close $email_file;

# Read the content of the email file and load each email as a hash table.
# for each {} is one email, once the email has been loaded into the hash tables fully
# push the email into the email array for later assessment.

# Holds the current email.
my $email = {};

# The list of emails.
my @email_list;

# Read line by line
LOAD_FILE :{

	foreach my $line (@file_content) {

		if(\$line == \$file_content[-1]){
			last LOAD_FILE;
		}

		$line =~ s/ +//;

		# Switch to sort each line into hash key and value.
		SWITCH: {

			if($line =~ /"type": "email",/){last SWITCH;}
			if($line =~ /"(.+?)": "(.+?)",?/) {$email->{$1} = $2; last SWITCH;}
			if($line =~ /},?/){push @email_list, $email;$email = {}; last SWITCH;}

		} # SWITCH

	} # foreach

} # LOAD_FILE

sub outPutEvent 
{
    my $startDateTime = $_[0];
    my $startTimeZone = $_[1];  
    my $endDateTime = $_[2];
    my $endTimeZone = $_[3];

                print "\t{\n";
            	print "\t\t\"start\" : {\n";
            	print "\t\t\t\"datetime\": \"" . $startDateTime . "\",\n";
            	print "\t\t\t\"timezone\": \"$startTimeZone\"\n";
            	print "\t\t},\n";
            	print "\t\t\"end\" : {\n";
            	print "\t\t\t\"datetime\": \"" . $endDateTime . "\",\n";
            	print "\t\t\t\"timezone\": \" $endTimeZone \"\n";
            	print "\t\t}\n";
            	print "\t},\n";
                
}


 sub monthsEvent
{
            my @refmatches = @{$_[0]};
            my $refYear =$_[1];
            my $refmonth = $_[2];
            my $mmTime = '00:00:00';
            #my $refTimeZone = $_[2];
            my $refTZ = $email_list[0]->{'timeZone'};
            my $refTimeZone = $refTZ;
            
            for(my $i=0; $i< scalar(@refmatches); $i++)
            {
                        
                #my $refTimeZone = \@email->{'timeZone'};
                
                
                if($refmatches[$i] =~ s/$refmonth/02/g)
                {
                    my $timestamp = $refmatches[$i];
                    my $eh; 
                    my $es;
                    my($day, $month, $starthour) = $refmatches[$i] =~ /(\d+)\s+(\d\d)\s+(\d+)/;
                    # for end formate
                    my ($datehour, $endtime) = split(/- /, $timestamp, 2);
                    if ($endtime=~/(\d+):?(\d+)?/){
                         $eh = $1;
                         $es = "00".":"."00".":"."00";
                        #print "eh: $eh\n";
                    }
                    if($endtime=~/(\d+):(\d+)/){
                         $es = "$2".":"."00".":"."00";
                        #print "es: $es\n";
                    }
                    
                    my $endsec = $es;
                    my $endhour = $eh;
                    
                      
                    #for start time  
                    my @startimestamp = (sprintf("%04d-%02d-%02dT%02d:%sZ", $refYear,$month,$day,$starthour,$mmTime));
                       
                    my @endtimestamp = (sprintf("%04d-%02d-%02dT%02d:%02sZ", $refYear,$month,$day,$endhour,$endsec));
                    
                    outPutEvent(@startimestamp, $refTimeZone, @endtimestamp, $refTimeZone);
                        
                }
                
                
                       
                }
}



my $MONTH = '(\d{1,2}\s\w+\s\S+\s-\s\S+)';


# Sort through the emails and extract the event dates.

READ_EMAILS :{

	# Ready output file
	open my $output, ">", $output_file or die "Could not create events file $!";

	print $output "[\n";
    
    foreach my $email (@email_list){
        
        # Check for all day events    
        my @matches = ($email->{'content'} =~ /$MONTH/g);
           
            #print "@matches";
            
           # For get the start year";
           my $startYear = $email_list[0]->{'sent'};
           my ($sYear) = $startYear =~ /(\d+)/;
           my $mmTime = '00:00:00';
          # my $refTimeZone = $email->{'timeZone'};
       
        
       # my @armonth = ("January", "Fabruary","March","April","May","June","July","August","September","October","November","December");
        
        
        
        #mysub(\@array);
        monthsEvent(\@matches, $sYear, "January");
        monthsEvent(\@matches, $sYear, "February");
        monthsEvent(\@matches, $sYear, "March");
        monthsEvent(\@matches, $sYear, "April");
        monthsEvent(\@matches, $sYear, "May");
        monthsEvent(\@matches, $sYear, "June");
        monthsEvent(\@matches, $sYear, "July");
        monthsEvent(\@matches, $sYear, "August");
        monthsEvent(\@matches, $sYear, "September");
        monthsEvent(\@matches, $sYear, "October");
        monthsEvent(\@matches, $sYear, "November");
        monthsEvent(\@matches, $sYear, "December");

        
        
        
        
            #for start time
          
              
            #for end time
              
           
         
        
        # # Check for 1 hour events or time frame events
        # if($email->{'content'} =~ / /){
            
            
            
        # }
        
        my $relative_date_regex = '(next (?:week|month|year)|(?:tomorrow|today)).*?(?:(mon(?:day)?|tues(?:day)?|wed(?:nesday)?|thur(?:sday)?|fri(?:day)?|sat(?:urday)?|sun(?:day)?).*?)?((?:[2][0-3]|[1]\d|0\d)[ \.:\-]?(?:[0-5]\d)|(?:1[0-2]|[1-9])(?:[\:\.\-](?:[0-5]\d))? ?(?:am|pm))';

        # # Check for relative events
        if($email->{'content'} =~ /$relative_date_regex/i){
            
        	my $week = $1;
        	my $day = $2 || 0;
            my $start = $3;
            my $end = $4 || 1;

            #print("$week: $day, $start, $end\n");

            if($week =~ /next week/i){

            	print $output "\t{\n";
            	print $output "\t\t\"start\" : {\n";
            	print $output "\t\t\t\"datetime\": \"" . $start . "\",\n";
            	print $output "\t\t\t\"timezone\": \"Australia/Melbourne\"\n"; # here is wrong for time zone.
            	print $output "\t\t},\n";
            	print $output "\t\t\"end\" : {\n";
            	print $output "\t\t\t\"datetime\": \" 1 hour \",\n";
            	print $output "\t\t\t\"timezone\": \"Australia/Melbourne\"\n";
            	print $output "\t\t}\n";
            	print $output "\t},\n";

            }
            
        }
        
    }
 
    print $output "]";

    close $output;

}
