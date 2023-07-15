{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.senpai;

  scfgValue = v: 
    if isString v then ''"${escape ["\""] v}"''
    else if isList v then concatMapStringsSep " " scfgValue v
    else generators.mkValueStringDefault {} v;

  scfgField = field: params:
    if isNull params then ""
    else "${field} ${scfgValue params}";

  scfgOf = fields: concatStringsSep "\n" (attrValues (mapAttrs scfgField fields));


  configText = scfgOf cfg.config;
in {
  options.programs.senpai = {
    enable = mkEnableOption "senpai";
    package = mkOption {
      type = types.package;
      default = pkgs.senpai;
      defaultText = literalExpression "pkgs.senpai";
      description = "The <literal>senpai</literal> package to use.";
    };
    config = mkOption {
      type = types.submodule {
        options = {
          address = mkOption {
            type = types.str;
            description = ''
              The address (host[:port]) of the IRC server. senpai uses TLS
              connections by default unless you specify no-tls option. TLS
              connections default to port 6697, plain-text use port 6667.
            '';
          };
          nickname = mkOption {
            type = types.str;
            description = ''
              Your nickname, sent with a NICK IRC message. It mustn't contain
              spaces or colons (:).
            '';
          };
          realname = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              Your real name, or actually just a field that will be available
              to others and may contain spaces and colons. Sent with the _USER_
               IRC message. By default, the value of nickname is used.
            '';
          };
          username = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              Your username, sent with the _USER_ IRC message and also used for
              SASL authentication. By default, the value of nickname is used.
            '';
          };
          password = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              Your password, used for SASL authentication. Note that it will
              reside world-readable in the Nix store.
            '';
          };
          password-cmd = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = ''
              Alternatively to providing your SASL authentication password
              directly in plaintext, you can specify a command to be run to
              fetch the password at runtime. This is useful if you store your
              passwords in a separate (probably encrypted) file using gpg or a
              command line password manager such as pass or gopass. If a
              password-cmd is provided, the value of password will be ignored
              and the first line of the output of password-cmd will be
	            used for login.
            '';
          };
          channel = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = ''
              A space separated list of channel names that senpai will
              automatically join at startup and server reconnect.
            '';
          };
          highlight = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = ''
              A list of keywords that will trigger a notification and a display
              indicator when said by others. By default, senpai will use your
              current nickname.
            '';
          };
          on-highlight-beep = mkOption {
            type = types.nullOr types.bool;
            default = null;
            description = ''
              Enable sending the bell character (BEL) when you are highlighted.
              Defaults to disabled.
            '';
          };
        };
      };
      example = literalExpression ''
        {
          addr = "libera.chat:6697";
          nick = "nicholas";
          password = "verysecurepassword";
        }
      '';
      description = ''
        Configuration for senpai. For a complete list of options, see
        <citerefentry><refentrytitle>senpai</refentrytitle>
        <manvolnum>5</manvolnum></citerefentry>.
      '';
    };  
    highlight-script = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Contents of the highlight script that is invoked when you are notified.
        See <citerefentry><refentrytitle>senpai</refentrytitle>
        <manvolnum>5</manvolnum></citerefentry> for a description of how the
        script is invoked.
      '';
    };
  };
 
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ cfg.package ];
      xdg.configFile."senpai/senpai.scfg".text = configText;
    }
    (mkIf (isString cfg.highlight-script) {
      xdg.configFile."senpai/highlight" = {
        text = cfg.highlight-script;
        executable = true;
      };
    })
  ]);

  meta.maintainers = [ hm.maintainers.malvo ];
}