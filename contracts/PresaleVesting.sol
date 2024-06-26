// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract PreSaleVesting is Ownable, ReentrancyGuard {
    // Token Address values
    IERC20 public immutable GVVToken;
    IERC20 public immutable USDT;

    // Funds wallet
    address payable private fundsWallet; // 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199

    // Presale Token Amount limits
    uint256[] public tokenLimsts = [20000000, 80000000, 150000000];

    // Presale token sold amounts
    uint256[] public TokenSoldAmount = [0, 0, 0];

    // Presale rounds prices
    uint256[] public tokenPricePerRound = [
        230000, //Private Round Stage 1 0.23 USDT
        340000, //Private Round Stage 2 0.34 USDT
        450000 //Public Round 0.45 USDT
    ];

    // Puase and Start the Presale system
    bool public _paused = true;

    // Staking Data
    struct Buyer {
        uint256 tokenAmount;
        uint256 buy_date;
        uint256 last_claim_date;
    }

    mapping(address => mapping(uint256 => Buyer)) public buyers;

    event TransferUSDT(
        address indexed fromAddress,
        address indexed toAddress,
        uint256 amount
    );

    event Withdraw(address indexed fundswallet, uint256 amountOfUSDT);

    event TransferGVVToken(
        address indexed fromAddress,
        address indexed toAddress,
        uint256 amount,
        uint256 date
    );

    constructor(address _gvvToken, address _usdt) Ownable(msg.sender) {
        GVVToken = IERC20(_gvvToken);
        USDT = IERC20(_usdt);
    }

    ///////////////////////////
    // setting functions by onwer 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    /////////////////////////// 
    function setFundsWallet(address _newAddr) external onlyOwner {
        fundsWallet = payable(_newAddr);
    }

    // toggle pause and start the system
    function ToggleemergencyPause() external onlyOwner {
        _paused = !_paused;
    }

    function startPresale() external onlyOwner {
        _paused = false;
    }

    ///////////////////////////
    // Modifiers
    ///////////////////////////
    // check system paused or not
    modifier whenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }

    ///////////////////////////
    // Functions for users
    ///////////////////////////
    function buyTokensByUSDT(uint256 _amount, uint256 round)
        external
        nonReentrant
        whenNotPaused
    {
        require(
            TokenSoldAmount[round] + _amount <= tokenLimsts[round],
            "Token is already sold out !"
        );
        require(_amount > 0, "amount should be more than 0");

        uint256 USDT_costs = _amount * tokenPricePerRound[round];

        uint256 allowance = USDT.allowance(msg.sender, address(this));
        require(
            allowance >= USDT_costs,
            "Allowance should be greater or equals to amount"
        );

        // Transfer USDT to this address
        USDT.transferFrom(msg.sender, address(this), USDT_costs);
        USDT.transfer(fundsWallet, USDT_costs);

        // Token sold plus
        TokenSoldAmount[round] += _amount;

        // Store buyer information and vesting details
        buyers[msg.sender][round].tokenAmount += _amount;
        buyers[msg.sender][round].buy_date = block.timestamp;
        buyers[msg.sender][round].last_claim_date = block.timestamp;

        emit TransferUSDT(msg.sender, address(this), USDT_costs);
    }


    ///////////////////////////
    // Functions for users
    ///////////////////////////
    function buyTokensByNativeCoin(uint256 _amount, uint256 round)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        require(
            TokenSoldAmount[round] + _amount <= tokenLimsts[round],
            "Token is already sold out !"
        );
        require(_amount > 0, "amount should be more than 0");

        require(msg.value > 0, "Value must be greater thatn 0");

        fundsWallet.transfer(msg.value);
 
        // Token sold plus
        TokenSoldAmount[round] += _amount;

        // Store buyer information and vesting details
        buyers[msg.sender][round].tokenAmount += _amount;
        buyers[msg.sender][round].buy_date = block.timestamp;
        buyers[msg.sender][round].last_claim_date = block.timestamp;

        emit TransferUSDT(msg.sender, address(this), msg.value);
    }

    receive() external payable {}

    function getUserBuyDate(address _user, uint256 _roundNum)
        external
        view
        returns (uint256)
    {
        return buyers[_user][_roundNum].buy_date;
    }

    function getUserBuyAmount(address _user, uint256 _roundNum)
        external
        view
        returns (uint256)
    {
        return buyers[_user][_roundNum].tokenAmount;
    }

    function getClaimableAmount(uint256 _roundNum) external view returns (uint256) {
        uint256 last_claim_date = buyers[msg.sender][_roundNum].last_claim_date;
        uint256 deltaMonths = getDeltaMonth(last_claim_date);
        uint256 payoutAmount = 0;

        if (_roundNum == 0) {
            // Private sale stage 1
            require(deltaMonths > 4, "Cliff period not reached");
            uint256 available_claim_amount = (buyers[msg.sender][_roundNum]
                .tokenAmount * 10) / 100; // 10% of bought token amount

            // calculate the number of months to pay out
            uint256 monthsToPayout = deltaMonths - 4;
            if (monthsToPayout > 0) {
                payoutAmount = available_claim_amount * monthsToPayout;
            }
        } else if (_roundNum == 1) {
            require(deltaMonths > 4, "Cliff period not reached");
            uint256 available_claim_amount = (buyers[msg.sender][_roundNum]
                .tokenAmount * 40) / 100; // 40% of bought token amount

            // Calculate the number of months to pay out
            uint256 monthsToPayout = deltaMonths - 4;
            if (monthsToPayout > 0) {
                payoutAmount = available_claim_amount * monthsToPayout;
            }
        } else {
            // Public Sale Round
            uint256 available_claim_amount = (buyers[msg.sender][_roundNum]
                .tokenAmount * 75) / 100; // 75% of bought token amount
            payoutAmount = available_claim_amount;
        }

        return payoutAmount;
    }

    function claimToken(uint256 _roundNum) external nonReentrant whenNotPaused {
        uint256 last_claim_date = buyers[msg.sender][_roundNum].last_claim_date;
        uint256 deltaMonths = getDeltaMonth(last_claim_date);

        if (_roundNum == 0) {
            // Private sale stage 1
            require(deltaMonths > 4, "Cliff period not reached");
            uint256 available_claim_amount = (buyers[msg.sender][_roundNum]
                .tokenAmount * 10) / 100; // 10% of bought token amount

            // calculate the number of months to pay out
            uint256 monthsToPayout = deltaMonths - 4;
            if (monthsToPayout > 0) {
                uint256 payoutAmount = available_claim_amount * monthsToPayout;
                GVVToken.transfer(msg.sender, payoutAmount);
                emit TransferGVVToken(address(this), msg.sender, payoutAmount, block.timestamp);
            }
        } else if (_roundNum == 1) {
            require(deltaMonths > 4, "Cliff period not reached");
            uint256 available_claim_amount = (buyers[msg.sender][_roundNum]
                .tokenAmount * 40) / 100; // 40% of bought token amount

            // Calculate the number of months to pay out
            uint256 monthsToPayout = deltaMonths - 4;
            if (monthsToPayout > 0) {
                uint256 payoutAmount = available_claim_amount * monthsToPayout;
                GVVToken.transfer(msg.sender, payoutAmount);
                emit TransferGVVToken(address(this), msg.sender, payoutAmount, block.timestamp);
            }
        } else {
            // Public Sale Round
            uint256 available_claim_amount = (buyers[msg.sender][_roundNum]
                .tokenAmount * 75) / 100; // 75% of bought token amount
            uint256 payoutAmount = available_claim_amount;
            GVVToken.transfer(msg.sender, payoutAmount);
            emit TransferGVVToken(address(this), msg.sender, payoutAmount, block.timestamp);
        }

        // Update the buy date to prevent claiming more than once per month
        buyers[msg.sender][_roundNum].last_claim_date = block.timestamp + 30 days; // Set the next claim date to be one month from the current claim
    }

    function getDeltaMonth(uint256 _buyDate) public view returns (uint256) {
        uint256 deltaMonths = (block.timestamp - _buyDate) /
            (30 * 24 * 60 * 60);
        return deltaMonths;
    }

    function withdraw() public onlyOwner returns (bool) {
        uint256 _totalUSDTInvestment = GVVToken.balanceOf(address(this));
        require(_totalUSDTInvestment > 0, "Insufficent Balance");

        USDT.transfer(fundsWallet, _totalUSDTInvestment);

        emit Withdraw(fundsWallet, _totalUSDTInvestment);
        return true;
    }
}
