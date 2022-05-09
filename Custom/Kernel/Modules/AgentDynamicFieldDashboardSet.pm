# --
# Kernel/Modules/AgentDynamicFieldDashboardSet.pm - Set dynamic field
# Copyright (C) 2012 - 2022 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentDynamicFieldDashboardSet;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::Log
    Kernel::System::Ticket
    Kernel::System::Web::Request
    Kernel::Output::HTML::Layout
    Kernel::System::DynamicField::Backend
    Kernel::System::DynamicField
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $LogObject          = $Kernel::OM->Get('Kernel::System::Log');
    my $MainObject         = $Kernel::OM->Get('Kernel::System::Main');

    my %GetParam;
    for my $WebParam ( qw(TicketID Value Field) ) {
        $GetParam{$WebParam} = $ParamObject->GetParam( Param => $WebParam ) || '';
    }

    # check needed stuff
    if ( !$GetParam{TicketID} ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No TicketID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # check permissions
    my $Access = $TicketObject->TicketPermission(
        Type     => 'rw',
        TicketID => $GetParam{TicketID},
        UserID   => $Self->{UserID}
    );

    # challenge token check for write action
    $LayoutObject->ChallengeTokenCheck();

    # redirect parent window to last screen overview on closed tickets
    if ( $Access ) {
        my $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
            Valid       => 1,
            ObjectType  => ['Ticket'],
        );

        my $DynamicFieldName = $ConfigObject->Get('SetDynamicFieldDashboard::DynamicField');
        my $DynamicFieldConfig;

        DYNAMICFIELD:
        for my $DFConfig ( @{$DynamicFields} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DFConfig);
            next DYNAMICFIELD if $DFConfig->{Name} ne $DynamicFieldName;

            $DynamicFieldConfig = $DFConfig;
            last DYNAMICFIELD;
        }

        # set the value
        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $GetParam{TicketID},
            Value              => $GetParam{Value},
            UserID             => $Self->{UserID},
        );

        $Success ||= 0;

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => qq~{"Success":$Success}~,
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    else {
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => '{"Success":0}',
            Type        => 'inline',
            NoCache     => 1,
        );
    }
}

1;
