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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address from, address to, uint256 value) external returns (bool);
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

    // Token Valus
    IERC20 public immutable GVVToken;  // GVV address
    IERC20 public immutable USDT; // USDT address 0x16cAB3aEFFCFfd0195A961ddeF5BA70dAb3ff0Bd
    
    // Wallet Values
    address private fundsWallet; // 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199
    uint256 public _totalUSDTInvestment = 0;

    // Puase and Start the Presale system
    bool public _paused = true;

    mapping(address => mapping (uint256 => uint256))[] _amountToBeClaimed;
    mapping(address => uint256) _buyDate;

    uint256[] public tokenSold = [
        0, //TokenSold initially should be zero on Priavet Round stage1
        0, //TokenSold initially should be zero on Priavet Round stage1
        0  //TokenSold initially should be zero on Public Round
    ];

    uint256[] public tokenPricePerRound = [
        230000, //Private Round Stage 1 0.23 USDT
        340000, //Private Round Stage 2 0.34 USDT
        450000 //Public Round 0.45 USDT
    ];

    uint256[] public tokenLimitPerRound = [
        20000000,
        80000000,
        150000000
    ];

    struct Buyer {
        uint256 totalAmount;
        uint256 vestingStartMonth;
        uint256 cliffMonth;
        mapping(uint256 => uint256) remainingVestingAmount; // Mapping to track remaining vesting amounts per month
    }

    mapping(address => Buyer) public buyers;

    uint256 public buyersCount;

    event TransferUSDT(address indexed fromAddress, address indexed toAddress, uint256 amount);

    event TransferGVVToken(address indexed fromAddress, address indexed toAddress, uint256 amount, uint256 date);

    event Withdraw(address indexed fundswallet, uint256 amountOfUSDT);

    constructor(address initialOwner, address _gvvTokenAddress, address _USDTTokenAddress, address _fundsWallet) Ownable (initialOwner) {
        GVVToken = IERC20(_gvvTokenAddress);
        USDT = IERC20(_USDTTokenAddress);
        fundsWallet = _fundsWallet;
    }

    // check system paused or not
    modifier whenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }
    
    // toggle pause and start the system
    function ToggleemergencyPause() external onlyOwner {
        _paused = !_paused;
    }


    function startPresale() external onlyOwner {
        _paused = false;
    }

    function SetFundsWallet(address _newFundsWallet) external onlyOwner {
        fundsWallet = _newFundsWallet;
    }

    // Set Token Limit values
    // 0: privatesale round stage 1
    // 1: privatesale round stage 2
    // 2: publicsale round
    function setTokenLimits(uint256 _periodNum, uint256 _newLimits) onlyOwner external {
        require(_periodNum < 3 ,"Invalid _periods");
        require(_periodNum >= 0 ,"Invalid _periods");
        tokenLimitPerRound[_periodNum] = _newLimits;
    }

    function setTokenPricePerRound(uint256 _periodNum, uint256 _newPrice) onlyOwner external {
        require(_periodNum < 3 ,"Invalid _periods");
        require(_periodNum >= 0 ,"Invalid _periods");
        tokenPricePerRound[_periodNum] = _newPrice;
    }

    function buyTokens(uint256 quantity, uint256 round) external nonReentrant whenNotPaused {
        require(tokenSold[round] < tokenLimitPerRound[round], "Presale has ended");
        require(quantity > 0, "Quantity should be more than 0");

        uint256 amount = (quantity * tokenPricePerRound[round]); // e.g. quantity = 300, tokePrice = 230000, amount = 69000000 // $69 USDT
        require(amount >= 10 * (10 ** 6), "Minimum amount"); // Minimum price should be $10 USDT
        
        uint256 buyerBlance = USDT.balanceOf(msg.sender);  // e.g. My balance is $880 USDT. buyerBalance should be 880 000 000
        require(buyerBlance >= amount, "Not enough blance");
        
        uint256 allowance = USDT.allowance(msg.sender, address(this));
        require(allowance >= amount, "Allowance should be greater or equals to amount");
        require(tokenSold[round] + quantity <= tokenLimitPerRound[round], "Tokens can be sold in this round is limited");
        
        USDT.transferFrom(msg.sender, address(this), amount);

        tokenSold[round] += quantity;

        _totalUSDTInvestment += amount;

        // Increment the buyersCount when a new buyer purchases tokens
        if (buyers[msg.sender].totalAmount == 0) {
            buyersCount++;
        }

        uint256 currentMonth = getCurrentMonth();

        // Store buyer information and vesting details
        buyers[msg.sender].totalAmount += quantity;
        buyers[msg.sender].vestingStartMonth = currentMonth;
        buyers[msg.sender].cliffMonth = currentMonth + 4; // Cliff of 4 months

        // Calculate token vesting details
        for (uint i = 0; i < 10; i++) {
            uint256 vestingAmount = quantity / 10;
            buyers[msg.sender].remainingVestingAmount[currentMonth + i + 4] += vestingAmount;
        }

        _buyDate[msg.sender] = currentMonth;

        // USDT.transfer(fundsWallet, amount);
        emit TransferUSDT(msg.sender, address(this), amount);
        // tokenVesting(quantity);
    }

    function claimToken() external nonReentrant whenNotPaused {
        uint256 currentMonth = getCurrentMonth();
        uint256 totalClaimableAmount = 0;

        for (uint i = buyers[msg.sender].vestingStartMonth; i < currentMonth; i++) {
            uint256 vestingAmount = buyers[msg.sender].remainingVestingAmount[i];
            require(vestingAmount > 0, "Nothing to claim this month");

            totalClaimableAmount += vestingAmount;
            buyers[msg.sender].remainingVestingAmount[i] = 0;
        }

        require(currentMonth >= buyers[msg.sender].cliffMonth, "Cliff period not reached");

        IERC20(GVVToken).transfer(msg.sender, totalClaimableAmount);
    }

    function getCurrentMonth() public view returns (uint256) {
        // return block.timestamp / (30 * 24 * 60 * 60);
        return block.timestamp / (60);
    }

    function withdraw() public onlyOwner returns (bool) {
        require(_totalUSDTInvestment > 0, "Insufficent Balance");

        USDT.transfer(fundsWallet, _totalUSDTInvestment);
        _totalUSDTInvestment = 0;

        emit Withdraw(fundsWallet, _totalUSDTInvestment);
        return true;
    }
}