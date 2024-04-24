pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

interface ISubmission {
    struct Jenish {
        address author;
        string line1;
        string line2;
        string line3;
    }

    function mintJenish(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) external;

    function counter() external view returns (uint256);

    function shareJenish(uint256 _id, address _to) external;

    function getMySharedJenishs() external view returns (Jenish[] memory);
}

contract JenishNFT is ERC721, ISubmission {
    Jenish[] public jenishs;
    mapping(address => mapping(uint256 => bool)) public sharedJenishs;
    uint256 public jenishCounter;

    constructor() ERC721("JenishNFT", "JENISH") {
        jenishCounter = 1;
    }

    function counter() external view override returns (uint256) {
        return jenishCounter;
    }

    function mintJenish(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) external override {
        string[3] memory jenishsStrings = [_line1, _line2, _line3];
        for (uint256 li = 0; li < jenishsStrings.length; li++) {
            string memory newLine = jenishsStrings[li];
            for (uint256 i = 0; i < jenishs.length; i++) {
                Jenish memory existingJenish = jenishs[i];
                string[3] memory existingJenishStrings = [
                    existingJenish.line1,
                    existingJenish.line2,
                    existingJenish.line3
                ];
                for (uint256 eHsi = 0; eHsi < 3; eHsi++) {
                    string memory existingJenishString = existingJenishStrings[
                        eHsi
                    ];
                    if (
                        keccak256(abi.encodePacked(existingJenishString)) ==
                        keccak256(abi.encodePacked(newLine))
                    ) {
                        revert JenishNotUnique();
                    }
                }
            }
        }

        _safeMint(msg.sender, jenishCounter);
        jenishs.push(Jenish(msg.sender, _line1, _line2, _line3));
        jenishCounter++;
    }

    function shareJenish(uint256 _id, address _to) external override {
        require(_id > 0 && _id <= jenishCounter, "Invalid jenish ID");

        Jenish memory jenishToShare = jenishs[_id - 1];
        require(jenishToShare.author == msg.sender, "NotYourJenish");

        sharedJenishs[_to][_id] = true;
    }

    function getMySharedJenishs()
        external
        view
        override
        returns (Jenish[] memory)
    {
        uint256 sharedJenishCount;
        for (uint256 i = 0; i < jenishs.length; i++) {
            if (sharedJenishs[msg.sender][i + 1]) {
                sharedJenishCount++;
            }
        }

        Jenish[] memory result = new Jenish[](sharedJenishCount);
        uint256 currentIndex;
        for (uint256 i = 0; i < jenishs.length; i++) {
            if (sharedJenishs[msg.sender][i + 1]) {
                result[currentIndex] = jenishs[i];
                currentIndex++;
            }
        }

        if (sharedJenishCount == 0) {
            revert NoJenishsShared();
        }

        return result;
    }

    error JenishNotUnique();
    error NotYourJenish();
    error NoJenishsShared();
}
