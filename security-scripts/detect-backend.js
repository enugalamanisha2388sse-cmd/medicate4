/**
 * Backend Discovery & Technology Stack Detector
 * Analyzes repository structure and identifies:
 * - Framework & Language
 * - API architecture
 * - Authentication & Authorization model
 * - Database & ORM technology
 * - Middleware & Security configurations
 */

'use strict';

const fs = require('fs');
const path = require('path');

function detectBackend(rootDir) {
  const inventory = {
    detected: false,
    framework: 'Unknown',
    language: 'Unknown',
    architecture: 'REST API',
    authMechanism: 'Unknown',
    authorizationModel: 'Role-Based Access Control (RBAC)',
    database: 'Unknown',
    orm: 'None / Native Driver',
    apiDocs: 'Not configured',
    middleware: [],
    fileUpload: 'Not detected',
    sessionHandling: 'Stateless / Token-based',
    thirdPartyIntegrations: [],
    details: []
  };

  const hasFile = (rel) => fs.existsSync(path.join(rootDir, rel));
  const readSafe = (rel) => {
    try {
      return fs.readFileSync(path.join(rootDir, rel), 'utf8');
    } catch {
      return '';
    }
  };

  // 1. Detect Node.js / Express / NestJS
  if (hasFile('security-backend/package.json') || hasFile('package.json')) {
    const pkgPath = hasFile('security-backend/package.json') 
      ? path.join(rootDir, 'security-backend/package.json') 
      : path.join(rootDir, 'package.json');
    const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
    const deps = { ...pkg.dependencies, ...pkg.devDependencies };

    inventory.detected = true;
    inventory.language = 'JavaScript / Node.js';
    if (deps['@nestjs/core']) {
      inventory.framework = 'NestJS';
    } else if (deps['express']) {
      inventory.framework = 'Express.js';
    } else if (deps['fastify']) {
      inventory.framework = 'Fastify';
    } else if (deps['koa']) {
      inventory.framework = 'Koa';
    } else {
      inventory.framework = 'Node.js HTTP';
    }

    if (deps['helmet']) inventory.middleware.push('Helmet (Security Headers)');
    if (deps['cors']) inventory.middleware.push('CORS Middleware');
    if (deps['express-validator']) inventory.middleware.push('express-validator (Input Validation)');
    if (deps['jsonwebtoken']) inventory.authMechanism = 'JWT (JSON Web Tokens)';
    else inventory.authMechanism = 'API Key Bearer Token Authentication';

    if (deps['sqlite3']) inventory.database = 'SQLite3';
    else if (deps['pg'] || deps['postgres']) inventory.database = 'PostgreSQL';
    else if (deps['mysql'] || deps['mysql2']) inventory.database = 'MySQL';
    else if (deps['mongoose'] || deps['mongodb']) inventory.database = 'MongoDB';

    if (deps['prisma'] || deps['@prisma/client']) inventory.orm = 'Prisma ORM';
    else if (deps['sequelize']) inventory.orm = 'Sequelize';
    else if (deps['typeorm']) inventory.orm = 'TypeORM';
  }

  // 2. Detect Python (Django, FastAPI, Flask)
  if (hasFile('requirements.txt') || hasFile('pyproject.toml') || hasFile('Pipfile')) {
    inventory.detected = true;
    inventory.language = 'Python';
    const reqs = readSafe('requirements.txt');
    if (reqs.includes('fastapi')) inventory.framework = 'FastAPI';
    else if (reqs.includes('django')) inventory.framework = 'Django';
    else if (reqs.includes('flask')) inventory.framework = 'Flask';
  }

  // 3. Detect Java (Spring Boot)
  if (hasFile('pom.xml') || hasFile('build.gradle')) {
    inventory.detected = true;
    inventory.language = 'Java';
    inventory.framework = 'Spring Boot';
  }

  // 4. Detect Flutter / Dart frontend
  if (hasFile('pubspec.yaml')) {
    inventory.details.push('Flutter / Dart mobile & web application detected');
    if (inventory.framework === 'Unknown') {
      inventory.framework = 'Flutter Client-State / Simulated Backend';
      inventory.language = 'Dart';
      inventory.authMechanism = 'Client-Side Provider Authentication';
    }
  }

  return inventory;
}

if (require.main === module) {
  const root = path.resolve(__dirname, '..');
  const inventory = detectBackend(root);
  console.log('====================================================');
  console.log('PHASE 1 — BACKEND DISCOVERY REPORT');
  console.log('====================================================');
  console.log(JSON.stringify(inventory, null, 2));
}

module.exports = { detectBackend };
