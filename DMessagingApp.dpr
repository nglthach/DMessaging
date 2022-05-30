program DMessagingApp;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DMessaging in 'Src\DMessaging.pas',
  DMessaging.Channel in 'Src\DMessaging.Channel.pas';

const
  MSG_NEW_USER = 'NewUser';
  
 type
   TUser = class
     Firstname, Lastname: string;
   public
     constructor Create(const aFirstname, aLastname: string);
   end;
   
constructor TUser.Create(const aFirstname, aLastname: string);
begin
  Firstname := aFirstname;
  Lastname := aLastname;
end;

begin
  try
    TMessaging.RegisterAnonymousSubscriber<TUser>(
        procedure (const MessageID: string; Arg: TUser)
          begin
            if MessageID = MSG_NEW_USER then
              Writeln('New user: ', Arg.Firstname, ' ', Arg.Lastname);
          end
    );

    TMessaging.SendThenFree(
        MSG_NEW_USER,
        TUser.Create('Foo', 'Bar')
    );
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
