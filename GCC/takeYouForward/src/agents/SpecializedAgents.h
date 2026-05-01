#ifndef SPECIALIZED_AGENTS_H
#define SPECIALIZED_AGENTS_H

#include "Agent.h"

// ============== TEAM LEAD AGENT ==============

class TeamLead : public Agent {
public:
    TeamLead(const std::string& name)
        : Agent(name, Role::TEAM_LEAD), projectStatus_("In Progress") {}
    
    void work() override;
    std::string getReport() override;
    
    // Team lead specific methods
    void assignTaskToTeam(const std::string& developerId, const Task& task);
    void reviewTeamProgress();
    void scheduleStandup();
    
private:
    std::string projectStatus_;
    int tasksCompleted_ = 0;
};

// ============== DEVELOPER AGENT ==============

class Developer : public Agent {
public:
    Developer(const std::string& name)
        : Agent(name, Role::DEVELOPER), skillLevel_(5), codeQuality_(0) {}
    
    void work() override;
    std::string getReport() override;
    
    // Developer specific methods
    void codeReview(const std::string& reviewerId);
    void implementFeature(const std::string& taskId);
    void fixBug(const std::string& bugId);
    void setSkillLevel(int level) { skillLevel_ = level; }
    
private:
    int skillLevel_;  // 1-10
    int codeQuality_;
    std::vector<std::string> implementedFeatures_;
};

// ============== TESTER AGENT ==============

class Tester : public Agent {
public:
    Tester(const std::string& name)
        : Agent(name, Role::TESTER), testsRun_(0), bugsfound_(0) {}
    
    void work() override;
    std::string getReport() override;
    
    // Tester specific methods
    void runTests(const std::string& featureId);
    void reportBug(const std::string& description, const std::string& severity);
    void verifyFix(const std::string& bugId);
    
private:
    int testsRun_;
    int bugsfound_;
    std::vector<std::string> foundBugs_;
};

// ============== REVIEWER AGENT ==============

class Reviewer : public Agent {
public:
    Reviewer(const std::string& name)
        : Agent(name, Role::REVIEWER), codeReviewsCompleted_(0), 
          approvalRate_(0.0), feedbackItems_(0) {}
    
    void work() override;
    std::string getReport() override;
    
    // Reviewer specific methods
    void reviewCode(const std::string& developerId, const std::string& taskId);
    void approvePullRequest(const std::string& prId);
    void requestChanges(const std::string& developerId, const std::string& feedback);
    
private:
    int codeReviewsCompleted_;
    double approvalRate_;
    int feedbackItems_;
    std::vector<std::string> reviews_;
};

#endif // SPECIALIZED_AGENTS_H
