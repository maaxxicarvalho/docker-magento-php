# docker tools for web development

This is just a simple repository that I created to persist the things I've been relying on to do my daily work.

Since the PHP Docker image brings no php-extensions and (for me) it's a boring process to keep adding them to each
project I created some Docker images with the extensions persisted.

I work with many projects and for each of them a PHP version will be required, that's why I have put together more
than one PHP version in the repository.

The images also include `gosu` (https://github.com/tianon/gosu)[https://github.com/tianon/gosu] which helps to solve
the root user Docker issue that can happen on Linux environments.
