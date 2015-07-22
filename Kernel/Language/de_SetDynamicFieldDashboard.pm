# --
# Kernel/Language/de_SetDynamicFieldDashboard.pm - the german translation of SetDynamicFieldDashboard
# Copyright (C) 2015 Perl-Services, http://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_SetDynamicFieldDashboard;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    $Lang->{'My tickets'} = 'Meine Tickets';
    $Lang->{'Saved'} = 'Gespeichert';

    return 1;
}

1;
