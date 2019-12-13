import
  confutils/defs, chronicles, chronos,
  eth/keys, eth/p2p/rlpx_protocols/waku_protocol

type
  Fleet* =  enum
    none
    beta
    staging

  WakuNodeConf* = object
    logLevel* {.
      desc: "Sets the log level."
      defaultValue: LogLevel.INFO
      name: "log-level" }: LogLevel

    tcpPort* {.
      desc: "TCP listening port."
      defaultValue: 30303
      name: "tcp-port" }: uint16

    udpPort* {.
      desc: "UDP listening port."
      defaultValue: 30303
      name: "udp-port" }: int

    discovery* {.
      desc: "Enable/disable discovery v4."
      defaultValue: true
      name: "discovery" }: bool

    noListen* {.
      desc: "Disable listening for incoming peers."
      defaultValue: false
      name: "no-listen" }: bool

    fleet* {.
      desc: "Select the fleet to connect to."
      defaultValue: Fleet.none
      name: "fleet" }: Fleet

    bootnodes* {.
      desc: "Comma separated enode URLs for P2P discovery bootstrap"
      name: "bootnodes" }: seq[string]

    staticnodes* {.
      desc: "Comma separated enode URLs to directly connect with"
      name: "staticnodes" }: seq[string]

    whisper* {.
      desc: "Enable the Whisper protocol."
      defaultValue: false
      name: "whisper" }: bool

    whisperBridge* {.
      desc: "Enable the Whisper protocol and bridge with Waku protocol"
      defaultValue: false
      name: "whisper-bridge" }: bool

    nodekey* {.
      desc: "P2P node private key as hex",
      defaultValue: newKeyPair()
      name: "nodekey" }: KeyPair
    # TODO: Add nodekey file option

    bootnodeOnly* {.
      desc: "Run only as bootnode"
      defaultValue: false
      name: "bootnode-only" }: bool

    rpc* {.
      desc: "Enable Waku RPC server",
      defaultValue: false
      name: "rpc" }: bool

    # TODO: get this validated and/or switch to TransportAddress
    rpcBinds* {.
      desc: "Enable Waku RPC server",
      name: "rpc-binds" }: seq[string]

    wakuMode* {.
      desc: "Select the Waku mode",
      defaultValue: WakuSan
      name: "waku-mode" }: WakuMode

    wakuPow* {.
      desc: "PoW requirement of Waku node",
      defaultValue: 0.002
      name: "waku-pow" }: float64

    # TODO:
    # - nat
    # - metrics
    # - discv5 + topic register
    # - mailserver functionality

proc parseCmdArg*(T: type KeyPair, p: TaintedString): T =
  try:
    # TODO: add isValidPrivateKey check from Nimbus?
    result.seckey = initPrivateKey(p)
    result.pubkey = result.seckey.getPublicKey()
  except CatchableError as e:
    raise newException(ConfigurationError, "Invalid private key")

proc completeCmdArg*(T: type KeyPair, val: TaintedString): seq[string] =
  return @[]