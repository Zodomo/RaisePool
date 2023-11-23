<a name="readme-top"></a>
<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
<h3 align="center">RaisePool</h3>

  <p align="center">
    A crowdfunded raise contract that incentivizes deposits by minting SocialCredits to participants.
    <br />
    <br />
    <a href="https://github.com/Zodomo/RaisePool/issues">Report Bug</a>
    ·
    <a href="https://github.com/Zodomo/RaisePool/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

RaisePool is a contract that facilitates collecting deposits for a fundraising effort. The contract will allow refunds if the soft target is not reached by the deadline. If the soft target is reached at any point, refunds are disabled and the recipient can withdraw. Once a withdrawal is processed, the contract locks and prevents any future attempted deposits. Deposits cannot exceed the hard cap at all, and if the final depositor exceeds it, they will have the overage refunded to them during bid processing.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* [![Ethereum][Ethereum.com]][Ethereum-url]
* [![Solidity][Solidity.sol]][Solidity-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

RaisePool was designed using Foundry, so I recommend familiarizing yourself with that if required.

### Prerequisites

* Foundry
  ```sh
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```

### Installation

1. Set up your RaisePool project using Foundry
   ```sh
   forge init ProjectName
   ```
2. Install RaisePool
   ```sh
   forge install zodomo/RaisePool --no-commit
   ```
3. Import RaisePool<br />
   Add the following above the beginning of your project's primary contract
   ```solidity
   import "../lib/RaisePool/src/RaisePool.sol";
   ```
4. Inherit the module<br />
   Add the following to the contract declaration
   ```solidity
   contract ProjectName is RaisePool {}
   ```
5. Populate constructor arguments<br />
   Add the following parameters and declaration to your constructor
   ```solidity
   constructor(
        address _owner,
        address _incentiveToken,
        uint40 _deadline,
        uint96 _softTarget,
        uint96 _hardTarget
    ) RaisePool(_owner, _incentiveToken, _deadline, _softTarget, _hardTarget) {}
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

The contract is automatically configured upon deployment. All state transitions happen automatically. Once soft target is reached, withdrawals automatically enable and refunds disable. Once `withdraw()` is called, the contract locks permanently.
<br />
<br />
Call `raise()` to contribute to the fundraising effort. The `receive()` function also calls `raise()`, so participants are able to send ETH directly to the RaisePool contract address and have their raise processed properly.
<br />
<br />
Raise participants can call `refund()` after the deadline has been reached but only if the soft target also hasn't been reached.


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the AGPL-3 License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Zodomo - [@0xZodomo](https://twitter.com/0xZodomo) - zodomo@proton.me - Zodomo.eth

Project Link: [https://github.com/Zodomo/RaisePool](https://github.com/Zodomo/RaisePool)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [MiyaMaker](https://miyamaker.com/)
* [Solady by Vectorized.eth](https://github.com/Vectorized/solady)
* [Openzeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/Zodomo/RaisePool.svg?style=for-the-badge
[contributors-url]: https://github.com/Zodomo/RaisePool/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Zodomo/RaisePool.svg?style=for-the-badge
[forks-url]: https://github.com/Zodomo/RaisePool/network/members
[stars-shield]: https://img.shields.io/github/stars/Zodomo/RaisePool.svg?style=for-the-badge
[stars-url]: https://github.com/Zodomo/RaisePool/stargazers
[issues-shield]: https://img.shields.io/github/issues/Zodomo/RaisePool.svg?style=for-the-badge
[issues-url]: https://github.com/Zodomo/RaisePool/issues
[Ethereum.com]: https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=Ethereum&logoColor=white
[Ethereum-url]: https://ethereum.org/
[Solidity.sol]: https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black
[Solidity-url]: https://soliditylang.org/