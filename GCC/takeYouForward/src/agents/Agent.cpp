#include "Agent.h"

// ============== AGENT BASE CLASS IMPLEMENTATION ==============

std::string Agent::getRoleString() const {
    switch(role_) {
        case Role::TEAM_LEAD: return "Team Lead";
        case Role::DEVELOPER: return "Developer";
        case Role::TESTER: return "Tester";
        case Role::REVIEWER: return "Reviewer";
        default: return "Unknown";
    }
}

void Agent::assignTask(const Task& task) {
    Task newTask = task;
    newTask.assignedTo = name_;
    newTask.status = Status::IDLE;
    tasks_.push_back(newTask);
    std::cout << "[" << name_ << "] Task assigned: " << task.id 
              << " - " << task.description << std::endl;
}

void Agent::completeTask(const std::string& taskId) {
    Task* task = findTask(taskId);
    if (task) {
        task->status = Status::DONE;
        std::cout << "[" << name_ << "] Task completed: " << taskId << std::endl;
    } else {
        std::cout << "[" << name_ << "] Task not found: " << taskId << std::endl;
    }
}

void Agent::listTasks() const {
    std::cout << "\n[" << name_ << " (" << getRoleString() << ") Tasks]:" << std::endl;
    if (tasks_.empty()) {
        std::cout << "  No tasks assigned." << std::endl;
        return;
    }
    for (const auto& task : tasks_) {
        task.print();
    }
}

void Agent::receiveMessage(const Message& msg) {
    messages_.push_back(msg);
    std::cout << "[" << name_ << "] Received message from " << msg.from << std::endl;
}

void Agent::sendMessage(const std::string& to, const std::string& content, 
                       const std::string& type) {
    Message msg(name_, to, content, type);
    std::cout << "[" << name_ << "] Sending " << type << " to " << to << std::endl;
}

void Agent::listMessages() const {
    std::cout << "\n[" << name_ << " Messages]:" << std::endl;
    if (messages_.empty()) {
        std::cout << "  No messages." << std::endl;
        return;
    }
    for (const auto& msg : messages_) {
        msg.print();
    }
}

Agent::Task* Agent::findTask(const std::string& taskId) {
    for (auto& task : tasks_) {
        if (task.id == taskId) {
            return &task;
        }
    }
    return nullptr;
}
