package API::Wunderlist::Class;

use Extorter;

# VERSION

sub import {
    my $class  = shift;
    my $target = caller;

    $class->extort::into($target, '*Data::Object::Class');
    $class->extort::into($target, '*API::Wunderlist::Signature');
    $class->extort::into($target, '*API::Wunderlist::Type');

    return;
}

1;
