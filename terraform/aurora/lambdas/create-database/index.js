// Origin: https://dzone.com/articles/aws-lambda-with-mysql-rds-and-api-gateway
// Ref: https://www.linkedin.com/pulse/como-deployar-aws-lambda-layers-com-terraform-e-nodejs-gasparoto/?trk=public_profile_article_view

const mysql = require('mysql'); 
const fs = require('fs');
let path = require("path");


exports.handler = async (event) => {

    // Important to be inside of the handler the connection
    var connection = mysql.createConnection({ 

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

    let file_sql = "./count.sql";

    if ( event && event.action ) {

        let action = event.action;

        file_sql = "./" + action + ".sql";
    }

    let content = fs.readFileSync(file_sql, {encoding:'utf8', flag:'r'});

    try {
        
        const data = await new Promise((resolve, reject) => {
            
            connection.query(content, function (err, results, fields) {
                if (err) {
                    connection.destroy();
                    reject(err);
                } else {
                    // connected!
                    console.log(results);
                    resolve(results);
                    connection.end(function (err) {
                        if (err) { 
                            reject(err) 
                        }
                    });
                }       
    
            });
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

