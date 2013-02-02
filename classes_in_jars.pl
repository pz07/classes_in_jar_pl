#!/usr/bin/env perl

sub process_jar {
    $jar_file = shift;
    my @result = qx (jar -tf $jar_file);

    foreach my $class (@result){
        if(not $classes{$class}){
            $classes{$class} = {"jars" => [$jar_file]};
        }

#        push %classes{$class}{"jars"}, $jar_file;
    }
}

sub search_in_dir {
    my $dir = shift;
    opendir(my $dh, $dir) || die "Can't open directory.";

    my $next_file;
    do{    
        $next_file = readdir $dh;

        if(-f "$dir/$next_file" && $next_file =~ /.*\.jar$/){
            print "$dir/$next_file\n";
            process_jar("$dir/$next_file");
        }

        if($next_file =~ /.*[a-zA-Z0-9].*/ && $recursive && -d "$dir/$next_file"){
            search_in_dir("$dir/$next_file");
        }
    }
    while($next_file);
    
    closedir $dh;
}


my @dirs = ();
$recursive = '';
%classes = ();

foreach my $arg (@ARGV) {
    if($arg =~ /-r/){
        $recursive = "true";
    }
    else{
        push @dirs, $arg;
    }
}

if(not @dirs){
    printf "Usage: perl print_classes_in_jars.pl <options> <directory to search> ...";
    printf "\n";
    printf "Option:";
    printf "\n";
    printf "-r - recursive search";
    printf "\n";

    exit;
}

printf "Directories to search: %s", @dirs;
printf "\n";
printf "Recursive search: %s", ($recursive ? "YES" : "NO");
printf "\n";


foreach my $dir (@dirs) {
    search_in_dir $dir;
}

foreach my $class (keys %classes) {
    my $count = 0;
    foreach my $jar ( @{$classes{$class}{"jars"}} ){
        $count++;
        print $jar;
        print " \n";
    }

    @jars = $classes{$class}{"jars"};

    print "Class: $class";
    print "   in jars: ";

    print "   jar count: $count\n";
    print "\n"
}




