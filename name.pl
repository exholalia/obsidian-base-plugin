#! /usr/bin/perl
use strict;
use warnings;

use feature 'say';
use FindBin qw($Bin);
use File::Basename;

my $template_description = "This is a plugin for Obsidian (https://obsidian.md).";
my $template_id = 'obsidian-base-plugin';

my %names;
my $plugin_id = '';
my $description = '';

# Parse command line arguments
sub parse {
    while (@ARGV) {
        my $arg = shift @ARGV;
        if ($arg eq '-h' || $arg eq '--help') {
            die "Usage: ./name [-d <description>] [--id <plugin_id>]\n";
        }
        elsif ($arg eq '-d') {
            $description = shift @ARGV // '';
        }
        elsif ($arg eq '--id') {
            $plugin_id = shift @ARGV // '';
        } else {
            die "Unknown argument: $arg\n";
        }
    }
}

# Get plugin names based on folder name
sub plugin_names {
    $plugin_id = (split('/', $Bin))[-1] unless $plugin_id ne '';
    $names{'id'} = $plugin_id;

    # Remove 'obsidian-' prefix and '-plugin' suffix
    $plugin_id =~ s/^obsidian-//;
    $plugin_id =~ s/-plugin$//;

    # Convert to PascalCase and Title Case
    (my $pascal_case = $plugin_id) =~ s/-(\w)/\U$1/g;
    $pascal_case = ucfirst($pascal_case);
    (my $title_case = $pascal_case) =~ s/([a-z])([A-Z])/$1 $2/g;
    
    $names{'ts'} = $pascal_case . 'Plugin';
    $names{'title'} = 'Obsidian ' . $title_case . ' Plugin';
    $names{'name'} = $title_case;
}

sub update_manifest {
    my $manifest_path = "$Bin/manifest.json";
    open my $fh, '<', $manifest_path or die "Could not open manifest '$manifest_path': $!";
    local $/;
    my $content = <$fh>;
    close $fh;

    $content =~ s/"id":\s*".*?"/"id": "$names{'id'}"/;
    $content =~ s/"name":\s*".*?"/"name": "$names{'name'}"/;

    if ($description ne '') {
        $content =~ s/"description":\s*".*?"/"description": "$description"/;
    }

    # print $content;

    open my $out_fh, '>', $manifest_path or die "Could not open '$manifest_path' for writing: $!";
    print $out_fh $content;
    close $out_fh;
}

sub update_package_json {
    my $package_path = "$Bin/package.json";
    open my $fh, '<', $package_path or die "Could not open package.json '$package_path': $!";
    local $/;
    my $content = <$fh>;
    close $fh;

    $content =~ s/"name":\s*".*?"/"name": "$names{'id'}"/;
    if ($description ne '') {
        $content =~ s/"description":\s*".*?"/"description": "$description"/;
    }

    # print $content;

    open my $out_fh, '>', $package_path or die "Could not open '$package_path' for writing: $!";
    print $out_fh $content;
    close $out_fh;
}

sub update_main_ts {
    my $main_ts_path = "$Bin/src/main.ts";
    open my $fh, '<', $main_ts_path or die "Could not open main.ts '$main_ts_path': $!";
    local $/;
    my $content = <$fh>;
    close $fh;

    $content =~ s/class\s+\w+\s+extends\s+Plugin/class $names{'ts'} extends Plugin/;

    # print $content;

    open my $out_fh, '>', $main_ts_path or die "Could not open '$main_ts_path' for writing: $!";
    print $out_fh $content;
    close $out_fh;
}

sub update_readme_md {
    my $readme_path = "$Bin/README.md";
    open my $fh, '<', $readme_path or die "Could not open README.md '$readme_path': $!";
    local $/;
    my $content = <$fh>;
    close $fh;

    $content =~ s/#\s+.*?Plugin/# $names{'title'}/;

    if ($description ne '') {
        # If there's only the standard description,
        # Replace it with the new description.
        # Otherwise, prepend the text with the new description.
        if ($content =~ /# $names{'title'}\s*\n\n(.*?)\n\n/s) {
            my $current_desc = $1;
            if ($current_desc eq $description) { # Skip if same
                $content =~ s/(# $names{'title'}\s*\n\n)(.*?)(\n\n)/$1$description$3/s;
            } elsif ($current_desc eq $template_description) { # Replace standard description
                $content =~ s/(# $names{'title'}\s*\n\n)(.*?)(\n\n)/$1$description$3/s;
            } else { # Prepend new description
                $content =~ s/(# $names{'title'}\s*\n\n)/$1$description\n\n/s;
            }
        } else {
            $content =~ s/(# $names{'title'}\s*\n)/$1$description\n\n/;
        }
    }

    # Update templated repository url if it exists
    $content =~ s/$template_id/$names{'id'}/g;

    open my $out_fh, '>', $readme_path or die "Could not open '$readme_path' for writing: $!";
    print $out_fh $content;
    close $out_fh;
}

sub main {
    parse();
    plugin_names();

    # Check before proceeding
    say "Please confirm the following plugin names:";
    say "Plugin ID: $names{'id'}";
    say "TypeScript Class Name: $names{'ts'}";
    say "Plugin Title: $names{'title'}";
    say "Plugin Description: " . $description;

    say "Are these are correct? [Y/n]";
    my $response = <STDIN>;
    chomp $response;
    $response = 'y' if $response eq '';
    if (lc($response) ne 'y') {
        die "Aborting. Please rename the folder to or pass in your desired plugin ID with the --id option.\n";
    }

    update_manifest();
    update_package_json();
    update_main_ts();
    update_readme_md();
}

main();