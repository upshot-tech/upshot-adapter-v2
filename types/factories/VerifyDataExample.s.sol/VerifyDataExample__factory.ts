/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import {
  Contract,
  ContractFactory,
  ContractTransactionResponse,
  Interface,
} from "ethers";
import type { Signer, ContractDeployTransaction, ContractRunner } from "ethers";
import type { NonPayableOverrides } from "../../common";
import type {
  VerifyDataExample,
  VerifyDataExampleInterface,
} from "../../VerifyDataExample.s.sol/VerifyDataExample";

const _abi = [
  {
    type: "function",
    name: "IS_SCRIPT",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "bool",
        internalType: "bool",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "run",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
] as const;

const _bytecode =
  "0x6080604052600b805461ff01600160b81b03191676238d0abd53fc68fafa0ccd860446e381b400b5be01000117905534801561003a57600080fd5b5061089b8061004a6000396000f3fe608060405234801561001057600080fd5b50600436106100365760003560e01c8063c04062261461003b578063f8ccbf4714610045575b600080fd5b61004361006c565b005b600b546100589062010000900460ff1681565b604051901515815260200160405180910390f35b60405163c1978d1f60e01b815260206004820152601960248201527f5343524950545f52554e4e45525f505249564154455f4b4559000000000000006044820152600090737109709ecfa91a80626ff3989d68f67f5b1dd12d9063c1978d1f90606401602060405180830381865afa1580156100ec573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906101109190610638565b6040516001625e79b760e01b0319815260048101829052909150600090737109709ecfa91a80626ff3989d68f67f5b1dd12d9063ffa1864990602401602060405180830381865afa158015610169573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061018d9190610651565b60405163ce817d4760e01b815260048101849052909150737109709ecfa91a80626ff3989d68f67f5b1dd12d9063ce817d4790602401600060405180830381600087803b1580156101dd57600080fd5b505af11580156101f1573d6000803e3d6000fd5b505050506102346040518060400160405280601781526020017f42726f61646361737420737461727465642062792025730000000000000000008152508261058c565b600060405180608001604052806001815260200161012c426102569190610681565b81526020016701b69b4ba630f34e81526020016040518060200160405280600081525081525090506000600b60039054906101000a90046001600160a01b03166001600160a01b0316631292835d836040518263ffffffff1660e01b81526004016102c19190610729565b602060405180830381865afa1580156102de573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906103029190610638565b905060008080737109709ecfa91a80626ff3989d68f67f5b1dd12d63e341eaa48861035a877f19457468657265756d205369676e6564204d6573736167653a0a3332000000006000908152601c91909152603c902090565b6040516001600160e01b031960e085901b16815260048101929092526024820152604401606060405180830381865afa15801561039b573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906103bf919061073c565b604080516001808252818301909252939650919450925060009190816020015b6103e76105f6565b8152602001906001900390816103df579050506040805180820190915260608101859052608081018490526001600160f81b031960f887901b1660a08201529091508060a181016040516020818303038152906040528152602001878152508160008151811061045957610459610779565b6020026020010181905250600b60039054906101000a90046001600160a01b03166001600160a01b0316636214bda16040518060400160405280848152602001604051806020016040528060008152508152506040518263ffffffff1660e01b81526004016104c8919061078f565b6020604051808303816000875af11580156104e7573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061050b9190610638565b507f885cb69240a935d632d79c317109709ecfa91a80626ff3989d68f67f5b1dd12d60001c6001600160a01b03166376eadd366040518163ffffffff1660e01b8152600401600060405180830381600087803b15801561056a57600080fd5b505af115801561057e573d6000803e3d6000fd5b505050505050505050505050565b6105d182826040516024016105a292919061083b565b60408051601f198184030181529190526020810180516001600160e01b031663319af33360e01b1790526105d5565b5050565b80516a636f6e736f6c652e6c6f67602083016000808483855afa5050505050565b6040518060400160405280606081526020016106336040518060800160405280600081526020016000815260200160008152602001606081525090565b905290565b60006020828403121561064a57600080fd5b5051919050565b60006020828403121561066357600080fd5b81516001600160a01b038116811461067a57600080fd5b9392505050565b818103818111156106a257634e487b7160e01b600052601160045260246000fd5b92915050565b6000815180845260005b818110156106ce576020818501810151868301820152016106b2565b506000602082860101526020601f19601f83011685010191505092915050565b805182526020810151602083015260408101516040830152600060608201516080606085015261072160808501826106a8565b949350505050565b60208152600061067a60208301846106ee565b60008060006060848603121561075157600080fd5b835160ff8116811461076257600080fd5b602085015160409095015190969495509392505050565b634e487b7160e01b600052603260045260246000fd5b600060208083526060830184516040808487015282825180855260808801915060808160051b8901019450858401935060005b8181101561081257888603607f19018352845180518588526107e6868901826106a8565b91890151888303898b01529190506107fe81836106ee565b9750505093860193918601916001016107c2565b50505092860151858303601f1901938601939093525061083281836106a8565b95945050505050565b60408152600061084e60408301856106a8565b905060018060a01b0383166020830152939250505056fea2646970667358221220ea67d583c0cff5e804594435cc5e7f6ec0356eaefc101db1edbd5e7127aa66d864736f6c63430008150033";

type VerifyDataExampleConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: VerifyDataExampleConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class VerifyDataExample__factory extends ContractFactory {
  constructor(...args: VerifyDataExampleConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override getDeployTransaction(
    overrides?: NonPayableOverrides & { from?: string }
  ): Promise<ContractDeployTransaction> {
    return super.getDeployTransaction(overrides || {});
  }
  override deploy(overrides?: NonPayableOverrides & { from?: string }) {
    return super.deploy(overrides || {}) as Promise<
      VerifyDataExample & {
        deploymentTransaction(): ContractTransactionResponse;
      }
    >;
  }
  override connect(runner: ContractRunner | null): VerifyDataExample__factory {
    return super.connect(runner) as VerifyDataExample__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): VerifyDataExampleInterface {
    return new Interface(_abi) as VerifyDataExampleInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): VerifyDataExample {
    return new Contract(address, _abi, runner) as unknown as VerifyDataExample;
  }
}