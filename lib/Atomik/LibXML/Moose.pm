# $Id: /mirror/coderepos/lang/perl/Atomik/trunk/lib/Atomik/LibXML/Moose.pm 67838 2008-08-05T05:08:34.471338Z daisuke  $

package Atomik::LibXML::Moose;
use strict;
use warnings;
use Carp qw(confess);
use Scalar::Util qw(blessed);

{
    my $GET_CALLER = sub {
        my $caller;
        my $i = 0;
        do {
            $caller = caller($i++);
        } while ($caller->isa(__PACKAGE__));
        return $caller;
    };

    my $has_atomik_object = Class::MOP::subname('Atomik::LibXML::Moose::has_atomik_object' => sub ($;%) {
        my $method = shift;
        my %args = @_;
        my $class = $GET_CALLER->();

        my $tag = $args{tag} ||
            confess "'tag' argument is required for '$method'";
        my $object_class = $args{class} || 
            confess "'class' argument is required for '$method'";

        my $fq_method = join('::', $class, $method);
        no strict 'refs';
        *{$fq_method} = sub {
            my $self = shift;
            my $namespace = $self->namespace;
            my $version = $self->version;
            my $storage = $self->storage;
            my ($node) =  $storage->findnodes_from_tagname(namespace => $namespace, tag => $tag);
            return $object_class->new(
                namespace => $namespace,
                version   => $version,
                storage   => (blessed $storage)->from_any( $node )
            )
        }
    });

    my %exports = (
        has_atomik_object => sub {
            my $class = shift;
            return $has_atomik_object
        },
        has_atomik_object_list => sub {
            my $class = shift;
            return Class::MOP::subname('Atomik::LibXML::Moose::has_atomik_object_list' => sub ($;%) {
                my $method = shift;
                my %args = @_;
                my $class = $GET_CALLER->();

                my $tag = $args{tag} ||
                    confess "'tag' argument is required for '$method'";
                my $object_class = $args{class} || 
                    confess "'class' argument is required for '$method'";

                my $fq_method = join('::', $class, $method);
                no strict 'refs';
                *{$fq_method} = sub {
                    my $self = shift;
                    my $namespace = $self->namespace;
                    my $version = $self->version;
                    my $storage = $self->storage;
                    map {
                        $object_class->new(
                            namespace => $namespace,
                            version   => $version,
                            storage   => (blessed $storage)->from_any( $_ )
                        )
                    } $storage->findnodes_from_tagname(namespace => $namespace, tag => $tag);
                };

                $fq_method = join('::', $class, "add_$method");
                *{$fq_method} = sub {
                    my $self = shift;
                    my $object;
                    if (@_ == 1 && blessed $_[0]) {
                        $object = shift;
                    } else {
                        $object = $object_class->new(@_);
                    }
                    $self->storage->libxml->appendChild(
                        $object->storage->libxml
                    );
                };

                if (my $singular = $args{singular}) {
                    $has_atomik_object->($singular, %args);
                }
            });
        },
        has_atomik_child => sub {
            my $class = shift;
            return Class::MOP::subname('Atomik::LibXML::Moose::has_atomik_child' => sub ($;%) {
                my $method = shift;
                my %args = @_;
                my $class = $GET_CALLER->();

                my $tag = $args{tag} || $method;
                my $fq_method = join('::', $class, $method);
                no strict 'refs';
                *{$fq_method} = sub {
                    my $self = shift;
                    my $namespace = $self->namespace;
                    my $version = $self->version;
                    my $storage = $self->storage;
                    if (@_) {
                        return $storage->set_child(
                            namespace => $namespace,
                            tag       => $tag,
                            content   => $_[0]
                        );
                    } else {
                        return $storage->findchildren_from_tagname(
                            namespace => $namespace, tag => $tag, strip => 1);
                    }
                };
            })
        },
        has_atomik_attr => sub {
            my $class = shift;
            return Class::MOP::subname('Atomik::LibxML::Moose::has_atomik_child' => sub ($;%) {
                my $method = shift;
                my %args = @_;
                my $class = $GET_CALLER->();

                my $attr = $args{attr} || $method;
                my $fq_method = join('::', $class, $method);
                no strict 'refs';
                *{$fq_method} = sub {
                    my $self = shift;
                    if (@_) {
warn "SETTING $attr to $_[0]";
                        return $self->storage->set_attr(
                            attr  => $attr,
                            value => $_[0]
                        );
                    } else {
                        return $self->storage->find_attr(attr => $attr, strip => 1);
                    }
                };
            });
        },
        has_atomik_versioned_element => sub {
            my $class = shift;
            return Class::MOP::subname('Atomik::LibXML::Moose::has_atomik_versioned_element' => sub ($;%) {
                my $class = $GET_CALLER->();
                my ($method, %def) = @_;
                my $one_oh = $def{'1.0'} || confess "no 1.0 name given for $method";
                my $zero_three = $def{'0.3'} || confess "no 0.3 name given for $method";

                my $fq_method = join('::', $class, $method);
                no strict 'refs';
                *{$fq_method} = sub {
                    my $self = shift;
                    my $namespace = $self->namespace;
                    my $version   = $self->version;
                    my $tag;
                    if ($version eq '0.3') {
                        $tag = $zero_three;
                    } elsif ($version eq '1.0') {
                        $tag = $one_oh;
                    } else {
                        confess "Could not find sensible tagname to look for for version '$version'";
                    }

                    return @_ ?
                        $self->element_set(namespace => $namespace, tag => $tag, value => $_[0]) :
                        $self->element_get(namespace => $namespace, tag => $tag);
                };
            });
        }
    );

    my $exporter = Sub::Exporter::build_exporter(
        {
            exports => \%exports,
            groups  => { default => [':all'] }
        }
    );

    sub import {
        return if caller() eq 'main';
        goto $exporter;
    }
}

1;
