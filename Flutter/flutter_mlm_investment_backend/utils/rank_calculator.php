<?php
require_once __DIR__ . '/../config/database.php';

class RankCalculator {
    private $db;
    private $conn;

    // Rank Definitions
    private const RANKS = [
        'Basic' => [
            'min_team' => 0,
            'min_investment' => 0,
            'next_rank' => 'Bronze'
        ],
        'Bronze' => [
            'min_team' => 10,
            'min_investment' => 5000,
            'next_rank' => 'Silver'
        ],
        'Silver' => [
            'min_team' => 50,
            'min_investment' => 20000,
            'next_rank' => 'Gold'
        ],
        'Gold' => [
            'min_team' => 200,
            'min_investment' => 100000,
            'next_rank' => 'Diamond'
        ],
        'Diamond' => [
            'min_team' => 1000,
            'min_investment' => 500000,
            'next_rank' => null
        ]
    ];

    public function __construct() {
        $this->db = Database::getInstance();
        $this->conn = $this->db->getConnection();
    }

    public function calculateUserRank($userId) {
        try {
            // 1. Get Total Team Size
            $teamStmt = $this->conn->prepare("
                SELECT COUNT(*) as total_team 
                FROM genealogy 
                WHERE sponsor_id = ?
            ");
            $teamStmt->execute([$userId]);
            $teamSize = $teamStmt->fetch()['total_team'] ?? 0;

            // 2. Get Total Personal Investment
            $invStmt = $this->conn->prepare("
                SELECT SUM(amount) as total_invested 
                FROM user_investments 
                WHERE user_id = ? AND status = 'active'
            ");
            $invStmt->execute([$userId]);
            $totalInvested = $invStmt->fetch()['total_invested'] ?? 0;

            // 3. Determine Rank
            $currentRank = 'Basic';
            foreach (self::RANKS as $rank => $criteria) {
                if ($teamSize >= $criteria['min_team'] && 
                    $totalInvested >= $criteria['min_investment']) {
                    $currentRank = $rank;
                }
            }

            // 4. Update User Rank in DB
            $this->updateUserRank($userId, $currentRank);

            // 5. Calculate Progress to Next Rank
            $nextRankData = $this->getNextRankProgress($currentRank, $teamSize, $totalInvested);

            return [
                'current_rank' => $currentRank,
                'team_size' => (int)$teamSize,
                'total_invested' => (float)$totalInvested,
                'next_rank' => $nextRankData
            ];

        } catch (Exception $e) {
            error_log("Error calculating rank for user $userId: " . $e->getMessage());
            return null;
        }
    }

    private function updateUserRank($userId, $rank) {
        // Check if rank changed
        $stmt = $this->conn->prepare("SELECT `rank` FROM users WHERE id = ?");
        $stmt->execute([$userId]);
        $oldRank = $stmt->fetch()['rank'] ?? 'Basic';

        if ($oldRank !== $rank) {
            $updateStmt = $this->conn->prepare("UPDATE users SET `rank` = ? WHERE id = ?");
            $updateStmt->execute([$rank, $userId]);
            
            // Log rank change history if needed
        }
    }

    private function getNextRankProgress($currentRank, $currentTeam, $currentInvested) {
        $nextRankName = self::RANKS[$currentRank]['next_rank'];
        
        if (!$nextRankName) {
            return null; // Max rank achieved
        }

        $criteria = self::RANKS[$nextRankName];
        
        $teamProgress = min(100, ($currentTeam / $criteria['min_team']) * 100);
        $investProgress = min(100, ($currentInvested / $criteria['min_investment']) * 100);
        
        // Overall progress is the minimum of the two requirements
        $overallProgress = min($teamProgress, $investProgress);

        return [
            'name' => $nextRankName,
            'required_team' => $criteria['min_team'],
            'required_investment' => $criteria['min_investment'],
            'team_progress' => $teamProgress,
            'investment_progress' => $investProgress,
            'overall_progress' => $overallProgress
        ];
    }
}
?>
