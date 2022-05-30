# DMessaging

A messaging lib for Delphi

## Example
```pascal
program DMessagingApp;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DMessaging in 'Src\DMessaging.pas',
  DMessaging.Channel in 'Src\DMessaging.Channel.pas',
  DMessaging.Tuples in 'Src\DMessaging.Tuples.pas',
  DMessaging.UIHelper in 'Src\DMessaging.UIHelper.pas';

const
  MSG_NEW_USER = 'NewUser';

begin
  try
    TMessaging.RegisterAnonymousSubscriber<TTuple<string, string>>(
        procedure (const MessageID: string; Arg: TTuple<string, string>)
          begin
            if MessageID = MSG_NEW_USER then
              Writeln('New user: ', Arg.Value1, ' ', Arg.Value2);
          end
    );

    TMessaging.SendThenFree(
        MSG_NEW_USER,
        TTuple<string, string>.Create('Foo', 'Bar')
    );
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
```

Output:
```
New user: Foo Bar
```
