// Origin: https://dzone.com/articles/aws-lambda-with-mysql-rds-and-api-gateway
// Ref: https://www.linkedin.com/pulse/como-deployar-aws-lambda-layers-com-terraform-e-nodejs-gasparoto/?trk=public_profile_article_view

const mysql = require('mysql'); 

const connection = mysql.createConnection({ 

    //following param coming from aws lambda env variable  
    host: process.env.RDS_HOSTNAME,
    user: process.env.RDS_USERNAME,
    password: process.env.RDS_PASSWORD, 
    port: process.env.RDS_PORT, 

    // calling direct inside code 
    connectionLimit: 60,  
    multipleStatements: true,

    // Prevent nested sql statements 
    connectionLimit: 1000, 
    connectTimeout: 60 * 60 * 1000,
    acquireTimeout: 60 * 60 * 1000,  
    timeout: 60 * 60 * 1000,  

    debug: true 
}); 

exports.handler = async (event) => {  

    try {  
        const data = await new Promise((resolve, reject) => {  
        connection.connect(function (err) {  
            if (err) {    
                reject(err);
            }      
            // TODO: to be replaced with string from file
            connection.query('CREATE DATABASE testdb',
        
            function (err, result) {  
                if (err) {  
                    console.log("Error->" + err);      
                    reject(err);        
            }           
            resolve(result);  
            });     
        })   

        }); 


        return {  
            statusCode: 200,   
            body: JSON.stringify(data)  
        } 
    } catch (err) {
        
        return {   
            statusCode: 400, 
            body: err.message   
        }  
    } 
}; 

