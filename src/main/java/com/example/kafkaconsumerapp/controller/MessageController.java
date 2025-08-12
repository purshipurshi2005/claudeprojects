package com.example.kafkaconsumerapp.controller;

import com.example.kafkaconsumerapp.entity.Message;
import com.example.kafkaconsumerapp.repository.MessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    @Autowired
    private MessageRepository messageRepository;

    @GetMapping
    public List<Message> getAllMessages() {
        return messageRepository.findAll();
    }

    @GetMapping("/topic/{topic}")
    public List<Message> getMessagesByTopic(@PathVariable String topic) {
        return messageRepository.findByTopicOrderByReceivedAtDesc(topic);
    }

    @GetMapping("/health")
    public String health() {
        return "Application is running!";
    }
}