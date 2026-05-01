#ifndef AGENT_H
#define AGENT_H

#include <string>
#include <vector>
#include <memory>
#include <iostream>
#include <chrono>
#include <sstream>

// ============== AGENT BASE CLASS ==============

class Agent {
public:
    enum class Role {
        TEAM_LEAD,
        DEVELOPER,
        TESTER,
        REVIEWER
    };
    
    enum class Status {
        IDLE,
        WORKING,
        WAITING,
        DONE
    };
    
    struct Task {
        std::string id;
        std::string description;
        std::string assignedTo;
        Status status;
        std::string priority;  // HIGH, MEDIUM, LOW
        std::string createdAt;
        
        Task(const std::string& id, const std::string& desc, const std::string& priority = "MEDIUM")
            : id(id), description(desc), assignedTo(""), status(Status::IDLE), priority(priority) {
            auto now = std::chrono::system_clock::now();
            auto time = std::chrono::system_clock::to_time_t(now);
            createdAt = std::ctime(&time);
        }
        
        void print() const {
            std::cout << "  [" << id << "] " << description 
                      << " (Priority: " << priority << ", Status: ";
            switch(status) {
                case Status::IDLE: std::cout << "IDLE"; break;
                case Status::WORKING: std::cout << "WORKING"; break;
                case Status::WAITING: std::cout << "WAITING"; break;
                case Status::DONE: std::cout << "DONE"; break;
            }
            std::cout << ")" << std::endl;
        }
    };
    
    struct Message {
        std::string from;
        std::string to;
        std::string content;
        std::string type;  // INFO, REQUEST, FEEDBACK, REPORT
        
        Message(const std::string& from, const std::string& to, 
                const std::string& content, const std::string& type = "INFO")
            : from(from), to(to), content(content), type(type) {}
        
        void print() const {
            std::cout << "  [" << type << "] From: " << from << " To: " << to 
                      << " => " << content << std::endl;
        }
    };
    
    // Constructor
    Agent(const std::string& name, Role role)
        : name_(name), role_(role), status_(Status::IDLE) {}
    
    virtual ~Agent() = default;
    
    // Getters
    std::string getName() const { return name_; }
    Role getRole() const { return role_; }
    Status getStatus() const { return status_; }
    std::string getRoleString() const;
    
    // Task management
    virtual void assignTask(const Task& task);
    virtual void completeTask(const std::string& taskId);
    virtual void listTasks() const;
    
    // Communication
    virtual void receiveMessage(const Message& msg);
    virtual void sendMessage(const std::string& to, const std::string& content, 
                            const std::string& type = "INFO");
    virtual void listMessages() const;
    
    // Virtual work methods - override in subclasses
    virtual void work() = 0;
    virtual std::string getReport() = 0;
    
    // Status management
    void setStatus(Status s) { status_ = s; }
    
protected:
    std::string name_;
    Role role_;
    Status status_;
    std::vector<Task> tasks_;
    std::vector<Message> messages_;
    
    // Helper to find task by ID
    Task* findTask(const std::string& taskId);
};

#endif // AGENT_H
