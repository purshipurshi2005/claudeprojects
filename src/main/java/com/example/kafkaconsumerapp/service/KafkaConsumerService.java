package com.example.kafkaconsumerapp.service;

import com.example.kafkaconsumerapp.entity.Message;
import com.example.kafkaconsumerapp.repository.MessageRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

@Service
public class KafkaConsumerService {

    private static final Logger logger = LoggerFactory.getLogger(KafkaConsumerService.class);

    @Autowired
    private MessageRepository messageRepository;

    @KafkaListener(topics = "test-topic", groupId = "consumer-group-1")
    public void consume(@Payload String message, 
                       @Header(KafkaHeaders.RECEIVED_TOPIC) String topic) {
        logger.info("Received message: {} from topic: {}", message, topic);
        
        try {
            Message msg = new Message(topic, message);
            messageRepository.save(msg);
            logger.info("Message saved to database with ID: {}", msg.getId());
        } catch (Exception e) {
            logger.error("Error saving message to database: ", e);
        }
    }
}